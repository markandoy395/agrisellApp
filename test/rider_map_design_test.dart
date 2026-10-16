import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_home_bottom_nav.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_map_visibility.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_content.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';
import 'support/rider_availability_fakes.dart';
import 'support/rider_route_phase7_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final cache = Directory('build/rider_map_test_cache')
      ..createSync(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => cache.absolute.path,
        );
  });
  setUpAll(() async {
    final font = FontLoader('Poppins');
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
    ]) {
      font.addFont(rootBundle.load('assets/fonts/Poppins/Poppins-$weight.ttf'));
    }
    await font.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  for (final navigation in [false, true]) {
    testWidgets(
      'map ${navigation ? 'navigation' : 'discovery'} adapts and keeps actions',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(() {
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
        });
        final location = FakeRiderLocationController();
        final route = RiderRouteController(
          service: Phase7RoutingService(),
          cache: MemoryPhase7RouteCache(),
        );
        final map = MapController();
        addTearDown(location.dispose);
        addTearDown(route.dispose);
        addTearDown(map.dispose);
        final request = phase7Request(DeliveryStage.goingToPickup);
        if (navigation) {
          await route.selectRequest(
            requestId: request.id,
            location: location.location!,
            requests: [request],
          );
        }
        final boundary = GlobalKey();
        var notifications = 0;
        var listCalls = 0;
        var manageCalls = 0;
        var messageCalls = 0;
        var exits = 0;
        var visibility = const RiderMapVisibility();
        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            builder: (context, child) =>
                RepaintBoundary(key: boundary, child: child),
            home: Scaffold(
              bottomNavigationBar: RiderHomeBottomNav(
                selectedIndex: 2,
                onSelected: (_) {},
              ),
              body: StatefulBuilder(
                builder: (context, setState) => RiderMapContent(
                  controller: location,
                  mapController: map,
                  requests: navigation ? [request] : [_pickup()],
                  farms: const [],
                  roadAccessConnections: const [],
                  farmDiscoveryError: null,
                  farmsLoading: false,
                  routeController: route,
                  riderId: 'rider-1',
                  filter: RiderMapFilter.all,
                  mapZoom: 15,
                  discoveryRadiusKm: 15,
                  navigationActive: navigation,
                  online: true,
                  onOnlineChanged: (_) {},
                  onFilterChanged: (_) {},
                  onMarkerTap: (_, _) {},
                  onFarmTap: (_) {},
                  onNavigateActive: (_) {},
                  onExitNavigation: () => exits++,
                  onRecenter: () {},
                  onRefresh: () {},
                  onOpenList: () => listCalls++,
                  onMapReady: () {},
                  onPositionChanged: (_, _) {},
                  onOpenNotifications: () => notifications++,
                  unreadNotifications: 2,
                  onOpenDelivery: (_) => manageCalls++,
                  onMessage: (_) => messageCalls++,
                  visibility: visibility,
                  onVisibilityChanged: (value) =>
                      setState(() => visibility = value),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        _expectPoppins(tester);
        expect(tester.takeException(), isNull);
        await _capture(
          tester,
          boundary,
          navigation ? 'navigation' : 'discovery',
        );
        if (navigation) {
          await tester.drag(
            find.byIcon(Icons.drag_handle),
            const Offset(0, -360),
          );
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Manage delivery'));
          await tester.tap(find.text('Manage delivery'));
          await tester.tap(find.text('Message'));
          expect(manageCalls, 1);
          expect(messageCalls, 1);
          await tester.tap(find.text('Exit'));
          expect(exits, 1);
        } else {
          await tester.tap(find.byTooltip('Notifications'));
          expect(notifications, 1);
          await tester.tap(find.byTooltip('Search pickups'));
          expect(listCalls, 1);
          await tester.tap(find.byTooltip('Map options'));
          await tester.pumpAndSettle();
          final headerPosition = tester.getTopLeft(find.text('Map options'));
          await tester.tap(find.text('Pickup requests'));
          await tester.pumpAndSettle();
          expect(visibility.pickups, isFalse);
          expect(
            tester
                .widget<RiderLiveMap>(find.byType(RiderLiveMap))
                .visibility
                .pickups,
            isFalse,
          );
          await tester.ensureVisible(find.text('Traffic conditions'));
          await tester.pumpAndSettle();
          expect(tester.getTopLeft(find.text('Map options')), headerPosition);
          expect(
            tester
                .widget<SwitchListTile>(
                  find.ancestor(
                    of: find.text('Traffic conditions'),
                    matching: find.byType(SwitchListTile),
                  ),
                )
                .onChanged,
            isNull,
          );
          await _capture(tester, boundary, 'options');
          await tester.tap(find.byTooltip('Close map options'));
          await tester.pumpAndSettle();
        }
        tester.view.physicalSize = const Size(320, 700);
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}

DeliveryRequest _pickup() => DeliveryRequest(
  id: 'preview-pickup',
  orderNumber: '#AG-123',
  productName: 'Fresh Tomatoes (5kg)',
  productImageUrl: 'assets/images/home/vegetable.png',
  sellerName: 'San Jose Farmers Market',
  buyerName: '',
  pickupLocation: const DeliveryLocation(
    address: 'Market',
    latitude: 8.481,
    longitude: 124.651,
  ),
  deliveryLocation: const DeliveryLocation(address: 'Delivery area'),
  pickupDeadline: DateTime(2030),
  deliveryFee: 60,
  distanceKm: 1.2,
  estimatedTravelMinutes: 5,
);

void _expectPoppins(WidgetTester tester) {
  for (final text in tester.widgetList<RichText>(find.byType(RichText))) {
    final family = text.text.style?.fontFamily;
    if (family == 'MaterialIcons') continue;
    expect(family, 'Poppins', reason: text.text.toPlainText());
  }
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  boundary.markNeedsPaint();
  await tester.pump();
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/rider_map_previews');
    await directory.create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
