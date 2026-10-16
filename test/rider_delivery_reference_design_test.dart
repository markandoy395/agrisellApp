import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/utils/rider_delivery_message.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_delivery_details_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_detail_route_preview.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_detail_progress.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_detail_product_card.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_detail_map_geometry.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_action_panel.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_evidence_view.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_quick_actions.dart';
import 'support/rider_detail_reference_fixture.dart';
import 'support/rider_test_models.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final cache = Directory('build/rider_detail_test_cache')
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
  for (final width in [320.0, 430.0]) {
    for (final active in [false, true]) {
      testWidgets(
        '${active ? 'active' : 'request'} detail reference at $width',
        (tester) async {
          _size(tester, width);
          final request = referenceDetailRequest(active: active);
          final controller = RiderDeliveryController(
            repository: InMemoryRiderDeliveryRepository(requests: [request]),
          )..updateProfile(verifiedRiderProfile());
          addTearDown(controller.dispose);
          final boundary = GlobalKey();
          var messages = 0;
          await tester.pumpWidget(
            MaterialApp(
              theme: AgrisellTheme.light,
              builder: (context, child) => RepaintBoundary(
                key: boundary,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(width == 320 ? 1.4 : 1),
                  ),
                  child: child!,
                ),
              ),
              home: RiderDeliveryDetailsScreen(
                request: request,
                controller: controller,
                riderId: 'rider-a',
                onOpenConversation: (_) async {
                  messages++;
                  return true;
                },
              ),
            ),
          );
          await tester.pumpAndSettle();
          tester
              .state<ScrollableState>(
                find
                    .descendant(
                      of: find.byType(ListView).first,
                      matching: find.byType(Scrollable),
                    )
                    .first,
              )
              .position
              .jumpTo(0);
          await tester.pumpAndSettle();
          expect(find.byType(RiderDetailProductCard), findsOneWidget);
          expect(
            find.text(active ? 'In progress' : 'New delivery request'),
            findsOneWidget,
          );
          final actionPanel = find.byType(RiderDeliveryActionPanel);
          final actionPosition = tester.getTopLeft(actionPanel);
          showRiderDeliveryMessage(
            tester.element(find.byType(RiderDeliveryDetailsScreen)),
            'Pickup Confirmation Required recorded.',
          );
          await tester.pumpAndSettle();
          expect(
            tester.getBottomRight(find.byType(SnackBar)).dy,
            lessThanOrEqualTo(tester.getTopLeft(actionPanel).dy),
          );
          await tester.tap(find.byTooltip('Close'));
          await tester.pumpAndSettle();
          await _capture(
            tester,
            boundary,
            '${active ? 'active' : 'request'}_${width.toInt()}_top',
          );
          await tester.scrollUntilVisible(
            find.byType(RiderDetailRoutePreview),
            250,
            scrollable: find
                .descendant(
                  of: find.byType(ListView).first,
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          await tester.pumpAndSettle();
          expect(find.byType(FlutterMap), findsOneWidget);
          expect(tester.getTopLeft(actionPanel), actionPosition);
          await _capture(
            tester,
            boundary,
            '${active ? 'active' : 'request'}_${width.toInt()}_route',
          );
          if (active) {
            await tester.scrollUntilVisible(
              find.byType(RiderDeliveryQuickActions),
              250,
              scrollable: find
                  .descendant(
                    of: find.byType(ListView).first,
                    matching: find.byType(Scrollable),
                  )
                  .first,
            );
            await Scrollable.ensureVisible(
              tester.element(find.text('Message')),
              alignment: .5,
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text('Message'));
            await tester.pumpAndSettle();
            expect(messages, 1);
            await tester.scrollUntilVisible(
              find.byType(RiderDeliveryEvidenceView),
              250,
              scrollable: find
                  .descendant(
                    of: find.byType(ListView).first,
                    matching: find.byType(Scrollable),
                  )
                  .first,
            );
            expect(find.text('Pickup photo'), findsOneWidget);
          } else {
            await tester.scrollUntilVisible(
              find.text('Other information'),
              250,
              scrollable: find
                  .descendant(
                    of: find.byType(ListView).first,
                    matching: find.byType(Scrollable),
                  )
                  .first,
            );
            expect(find.text('COD amount to collect'), findsOneWidget);
          }
          await tester.pumpAndSettle();
          await _capture(
            tester,
            boundary,
            '${active ? 'active' : 'request'}_${width.toInt()}_lower',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets(
    'route preview draws only supplied road geometry and keeps map action',
    (tester) async {
      _size(tester, 430);
      var opens = 0;
      for (final geometry in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: Scaffold(
              body: RiderDetailRoutePreview(
                request: referenceDetailRequest(geometry: geometry),
                onOpenMap: () => opens++,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byType(PolylineLayer),
          geometry ? findsOneWidget : findsNothing,
        );
        if (geometry) {
          final polyline = tester
              .widget<PolylineLayer>(find.byType(PolylineLayer))
              .polylines
              .single;
          expect(polyline.points.length, 3);
        } else {
          expect(
            find.textContaining('Road route not available yet'),
            findsOneWidget,
          );
        }
        expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
        await tester.tap(find.text('Open in Maps'));
      }
      expect(opens, 2);
      expect(riderDetailMapPoint(double.nan, 1), isNull);
      expect(riderDetailMapPoint(91, 1), isNull);
      expect(riderDetailMapPoint(1, 181), isNull);
    },
  );
  testWidgets('exception status never paints normal milestones complete', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RiderDetailProgress(
            status: DeliveryStatus.failed,
            events: [],
            nextAction: Text('No action'),
          ),
        ),
      ),
    );
    expect(find.textContaining('Failed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _size(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 844);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  boundary.markNeedsPaint();
  await tester.pump();
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/rider_delivery_detail_previews')
      ..createSync(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
