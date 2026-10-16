import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_home_bottom_nav.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_deliveries_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_filter_sheet.dart';
import 'support/rider_test_models.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_delivery_details_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final cache = Directory('build/rider_deliveries_design_cache')
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

  for (final tab in ['Requests', 'Active', 'History']) {
    testWidgets(
      '$tab matches deliveries layout and fits enlarged small screens',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(() {
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
        });
        final requests = tab == 'Requests'
            ? [_request('tomatoes', DeliveryStage.readyForPickup)]
            : [
                _request('vegetables', DeliveryStage.goingToPickup),
                _request('rice', DeliveryStage.completed),
                _request('greens', DeliveryStage.cancelled),
              ];
        final controller = RiderDeliveryController(
          repository: InMemoryRiderDeliveryRepository(requests: requests),
        )..updateProfile(verifiedRiderProfile());
        addTearDown(controller.dispose);
        if (tab == 'Requests') {
          controller.setOnline(true);
          controller.updateRequestEnvironment(
            state: RiderRequestAccessState.eligible,
            location: const RiderDeliverySearch(
              latitude: 8.48,
              longitude: 124.65,
            ),
            accuracyMeters: 5,
          );
        } else {
          await controller.applyAuthoritativeAvailability(
            RiderAvailability.deliveryReserved,
            loadRequests: false,
          );
        }
        await controller.load(riderId: 'rider-a');
        var mapCalls = 0;
        var notifications = 0;
        final boundary = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: RepaintBoundary(
              key: boundary,
              child: Scaffold(
                bottomNavigationBar: RiderHomeBottomNav(
                  selectedIndex: 1,
                  onSelected: (_) {},
                ),
                body: RiderDeliveriesScreen(
                  profile: verifiedRiderProfile(),
                  riderId: 'rider-a',
                  deliveryController: controller,
                  onOpenMap: () => mapCalls++,
                  onOpenNotifications: () => notifications++,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (tab != 'Requests') {
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byTooltip('Notifications'));
        expect(notifications, 1);
        if (tab == 'Requests') {
          expect(find.text('Accept'), findsOneWidget);
          expect(find.text('PHP 80.00'), findsOneWidget);
          expect(find.text('Private customer'), findsNothing);
          final headerPosition = tester.getTopLeft(
            find.text('Deliveries').first,
          );
          await tester.drag(find.byType(ListView), const Offset(0, -200));
          await tester.pumpAndSettle();
          expect(
            tester.getTopLeft(find.text('Deliveries').first),
            headerPosition,
          );
          await tester.drag(find.byType(ListView), const Offset(0, 1000));
          await tester.pumpAndSettle();
        } else if (tab == 'Active') {
          expect(find.text('Manage delivery'), findsOneWidget);
          await tester.ensureVisible(
            find.widgetWithText(OutlinedButton, 'Map'),
          );
          await tester.tap(find.widgetWithText(OutlinedButton, 'Map'));
          expect(mapCalls, 1);
          await tester.drag(find.byType(ListView), const Offset(0, 1000));
          await tester.pumpAndSettle();
        } else {
          expect(find.text('Completed - 10:00 AM'), findsOneWidget);
          await tester.enterText(find.byType(TextField), 'rice');
          await tester.pumpAndSettle();
          expect(find.text('Fresh rice (5kg)'), findsOneWidget);
          expect(find.text('Fresh greens (5kg)'), findsNothing);
          await tester.enterText(find.byType(TextField), '');
          await tester.tap(find.byTooltip('Filter history'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Cancelled').last);
          await tester.pumpAndSettle();
          expect(find.text('Fresh rice (5kg)'), findsNothing);
          await tester.tap(find.byTooltip('Filter history'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('All deliveries').last);
          await tester.pumpAndSettle();
          expect(find.text('Fresh rice (5kg)'), findsOneWidget);
        }
        _expectPoppins(tester);
        expect(tester.takeException(), isNull);
        await _capture(tester, boundary, tab.toLowerCase());
        tester.view.physicalSize = const Size(320, 700);
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('delivery details keeps tracking and actions in new design', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final request = _request('vegetables', DeliveryStage.goingToPickup);
    final controller = RiderDeliveryController(
      repository: InMemoryRiderDeliveryRepository(requests: [request]),
    );
    addTearDown(controller.dispose);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: RepaintBoundary(
          key: boundary,
          child: RiderDeliveryDetailsScreen(
            request: request,
            controller: controller,
            riderId: 'rider-a',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Delivery details'), findsOneWidget);
    expect(find.textContaining('Going to Pickup'), findsWidgets);
    expect(find.text('Arrive at pickup location'), findsOneWidget);
    _expectPoppins(tester);
    expect(tester.takeException(), isNull);
    await _capture(tester, boundary, 'details');
    await tester.scrollUntilVisible(
      find.text('Addresses'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Navigate'), findsNWidgets(2));
    await _capture(tester, boundary, 'details_addresses');
    expect(tester.takeException(), isNull);
  });

  testWidgets('filters retain custom values and validate earning ranges', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final boundary = GlobalKey();
    RiderRequestFilters? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        builder: (context, child) =>
            RepaintBoundary(key: boundary, child: child),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showRiderRequestFilterSheet(
                context,
                const RiderRequestFilters(
                  maximumPickupDistanceKm: 65,
                  category: 'Custom category',
                  pickupWithinMinutes: 45,
                  minimumFee: 125.5,
                ),
                categories: ['Vegetables'],
              ),
              child: const Text('Open filters'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();
    expect(find.text('Custom category'), findsOneWidget);
    expect(find.text('Within 45 min'), findsOneWidget);
    _expectPoppins(tester);
    await _capture(tester, boundary, 'filters');
    final applyPosition = tester.getTopLeft(find.text('Apply filters'));
    await tester.tap(find.text('Urgent only'));
    final fields = find.byType(TextFormField);
    await tester.ensureVisible(fields.last);
    expect(tester.getTopLeft(find.text('Apply filters')), applyPosition);
    await tester.enterText(fields.last, '100');
    await tester.ensureVisible(find.text('Apply filters'));
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();
    expect(find.text('Must be at least the minimum earning'), findsOneWidget);
    expect(result, isNull);
    await tester.enterText(fields.last, '250.75');
    await tester.ensureVisible(find.text('Apply filters'));
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();
    expect(result?.maximumPickupDistanceKm, 65);
    expect(result?.pickupWithinMinutes, 45);
    expect(result?.category, 'Custom category');
    expect(result?.minimumFee, 125.5);
    expect(result?.maximumFee, 250.75);
    expect(result?.urgentOnly, isTrue);
    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(result?.activeCount, 0);
    expect(tester.takeException(), isNull);
  });
}

DeliveryRequest _request(String id, DeliveryStage stage) => DeliveryRequest(
  id: id,
  orderNumber: '#AG-$id',
  productName: 'Fresh $id (5kg)',
  sellerName: 'San Jose Farmers Market',
  buyerName: 'Private customer',
  productCategory: 'Vegetables',
  productImageUrl: 'assets/images/home/vegetable.png',
  pickupLocation: const DeliveryLocation(
    address: 'San Jose Farmers Market, San Jose',
    latitude: 8.48,
    longitude: 124.65,
  ),
  deliveryLocation: const DeliveryLocation(
    address: 'Rivera Residence, Cabanatuan City',
    latitude: 8.49,
    longitude: 124.66,
  ),
  pickupDeadline: DateTime(2030),
  deliveryDeadline: DateTime(2030, 1, 1, 3),
  closedAt: DateTime(2026, 10, 15, 10),
  serviceArea: 'Cagayan de Oro',
  deliveryFee: 80,
  totalWeightKg: 5,
  distanceKm: 2,
  estimatedTravelMinutes: 10,
  pickupToDeliveryMinutes: 15,
  pickupToDeliveryDistanceKm: 4,
  assignedRiderId: stage == DeliveryStage.readyForPickup ? null : 'rider-a',
  stage: stage,
);

void _expectPoppins(WidgetTester tester) {
  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    if (richText.text.style?.fontFamily == 'MaterialIcons') continue;
    expect(
      richText.text.style?.fontFamily,
      'Poppins',
      reason: richText.text.toPlainText(),
    );
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
    final directory = Directory('build/rider_deliveries_previews');
    await directory.create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
