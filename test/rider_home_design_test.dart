import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_home_design_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_dashboard_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_home_bottom_nav.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'support/rider_dashboard_fixture.dart';
import 'support/rider_dashboard_fakes.dart';
import 'support/rider_test_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await font.load();
    await icons.load();
  });
  for (final online in [false, true]) {
    testWidgets(
      'rider home ${online ? 'online' : 'offline'} adapts and keeps actions',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(() {
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
        });
        final fixture = RiderDashboardFixture(
          dashboardRepository: FakeRiderDashboardRepository(),
          requests: online ? [assignedDeliveryRequest()] : [],
        );
        addTearDown(fixture.dispose);
        await fixture.availability.initialize(riderId: 'rider-a');
        if (online) {
          await fixture.availability.setOnline(true);
          await fixture.delivery.applyAuthoritativeAvailability(
            RiderAvailability.deliveryReserved,
            loadRequests: false,
          );
          await fixture.delivery.load(riderId: 'rider-a');
        }
        var notifications = 0;
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: RepaintBoundary(
              key: boundaryKey,
              child: Scaffold(
                bottomNavigationBar: RiderHomeBottomNav(
                  selectedIndex: 0,
                  onSelected: (_) {},
                ),
                body: RiderDashboardScreen(
                  profile: verifiedRiderProfile(),
                  riderId: 'rider-a',
                  deliveryController: fixture.delivery,
                  availabilityController: fixture.availability,
                  dashboardController: fixture.dashboard,
                  onOpenDeliveries: () {},
                  onOpenMap: () {},
                  onOpenMessages: () {},
                  onOpenEarnings: () {},
                  onOpenNotifications: () => notifications++,
                  onSafetySupport: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.widget<Switch>(find.byType(Switch)).value, online);
        await tester.tap(find.text('Notifications'));
        expect(notifications, 1);
        expect(tester.takeException(), isNull);
        _expectPoppins(tester);
        expect(RiderHomeDesignStyles.green, AgrisellColors.authGreen);
        expect(RiderHomeDesignStyles.background, AgrisellColors.homeBackground);
        expect(RiderHomeDesignStyles.headerBackground.gradient!.colors, [
          AgrisellColors.forestGreen,
          AgrisellColors.authGreen,
        ]);

        final state = online ? 'online' : 'offline';
        final headerPosition = tester.getTopLeft(find.text('Hello, Rider'));
        final statusPosition = tester.getTopLeft(find.text('Work status'));
        await _capturePreview(tester, boundaryKey, state);
        await tester.scrollUntilVisible(
          find.text('Safety and support'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(find.text('Hello, Rider')), headerPosition);
        expect(tester.getTopLeft(find.text('Work status')), statusPosition);
        _expectPoppins(tester);
        await _capturePreview(tester, boundaryKey, '${state}_details');
        expect(tester.takeException(), isNull);

        tester.view.physicalSize = const Size(320, 700);
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView), const Offset(0, 5000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}

void _expectPoppins(WidgetTester tester) {
  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    final family = richText.text.style?.fontFamily;
    if (family == 'MaterialIcons') continue;
    expect(
      family,
      'Poppins',
      reason: 'Incorrect font for ${richText.text.toPlainText()}',
    );
  }
}

Future<void> _capturePreview(
  WidgetTester tester,
  GlobalKey key,
  String name,
) async {
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  boundary.markNeedsPaint();
  await tester.pump();
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = Directory('build/rider_home_previews');
      await directory.create(recursive: true);
      await File(
        '${directory.path}/$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}
