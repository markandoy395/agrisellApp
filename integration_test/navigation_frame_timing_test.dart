import 'dart:convert';

import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_home_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_home_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_map_screen.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/marketplace_messaging_fakes.dart';
import '../test/support/rider_dashboard_fakes.dart';
import '../test/support/rider_dashboard_fixture.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('farmer navigation stays within the frame budget', (
    tester,
  ) async {
    final firstView = Stopwatch();

    final timings = await _measureFrames(() async {
      firstView.start();
      await tester.pumpWidget(
        MaterialApp(
          home: FarmerHomeScreen(
            messagingRepository: FakeMarketplaceMessagingRepository(
              actorRole: MarketplaceActorRole.farmer,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      firstView.stop();

      for (final label in const [
        'Messages',
        'Alerts',
        'Reserve',
        'Products',
        'Alerts',
        'Messages',
        'Products',
      ]) {
        await tester.tap(_navigationTab(label));
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(milliseconds: 100));
    });

    _recordRegressionMetrics(
      binding,
      'farmer_navigation',
      timings,
      firstViewElapsed: firstView.elapsed,
    );
  });

  testWidgets('rider map navigation stays within the frame budget', (
    tester,
  ) async {
    final repository = FakeRiderDashboardRepository();
    final fixture = RiderDashboardFixture(dashboardRepository: repository);
    addTearDown(fixture.dispose);
    final firstView = Stopwatch();

    final timings = await _measureFrames(() async {
      firstView.start();
      await tester.pumpWidget(
        MaterialApp(
          home: RiderHomeScreen(
            deliveryController: fixture.delivery,
            availabilityController: fixture.availability,
            dashboardController: fixture.dashboard,
            locationController: fixture.location,
          ),
        ),
      );
      await tester.pumpAndSettle();
      firstView.stop();
      expect(find.byType(RiderMapScreen), findsNothing);

      for (final label in const [
        'Map',
        'Home',
        'Profile',
        'Map',
        'Messages',
        'Deliveries',
        'Map',
        'Home',
      ]) {
        await tester.tap(_navigationTab(label));
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(milliseconds: 100));
    });

    _recordRegressionMetrics(
      binding,
      'rider_map_navigation',
      timings,
      firstViewElapsed: firstView.elapsed,
    );
  });
}

Future<List<FrameTiming>> _measureFrames(Future<void> Function() action) async {
  final timings = <FrameTiming>[];
  void collect(List<FrameTiming> values) => timings.addAll(values);

  SchedulerBinding.instance.addTimingsCallback(collect);
  try {
    await action();
    await Future<void>.delayed(const Duration(milliseconds: 500));
  } finally {
    SchedulerBinding.instance.removeTimingsCallback(collect);
  }
  return timings;
}

Finder _navigationTab(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is CustomBottomNavTab && widget.item.label == label,
    description: 'bottom navigation tab labeled $label',
  );
}

void _recordRegressionMetrics(
  IntegrationTestWidgetsFlutterBinding binding,
  String reportKey,
  List<FrameTiming> timings, {
  required Duration firstViewElapsed,
}) {
  final buildTimes = timings
      .map((timing) => timing.buildDuration.inMicroseconds)
      .toList(growable: false);
  final rasterTimes = timings
      .map((timing) => timing.rasterDuration.inMicroseconds)
      .toList(growable: false);
  final uiOverBudget = buildTimes.where((time) => time > 16667).length;
  final rasterOverBudget = rasterTimes.where((time) => time > 16667).length;
  final uiSignificantlySlow = buildTimes.where((time) => time > 33334).length;
  final rasterSignificantlySlow = rasterTimes
      .where((time) => time > 33334)
      .length;

  final worstBuild = buildTimes.fold<int>(
    0,
    (worst, time) => time > worst ? time : worst,
  );
  final worstRaster = rasterTimes.fold<int>(
    0,
    (worst, time) => time > worst ? time : worst,
  );
  final report = <String, dynamic>{}
    ..['frame_count'] = timings.length
    ..['frame_build_times'] = buildTimes
    ..['frame_rasterizer_times'] = rasterTimes
    ..['worst_frame_build_time_millis'] = worstBuild / 1000
    ..['worst_frame_rasterizer_time_millis'] = worstRaster / 1000
    ..['first_view_elapsed_millis'] = firstViewElapsed.inMilliseconds
    ..['ui_frames_over_16_67ms'] = uiOverBudget
    ..['raster_frames_over_16_67ms'] = rasterOverBudget
    ..['ui_frames_over_33_33ms'] = uiSignificantlySlow
    ..['raster_frames_over_33_33ms'] = rasterSignificantlySlow;
  binding.reportData ??= <String, dynamic>{};
  binding.reportData![reportKey] = report;
  debugPrint('$reportKey frame metrics: ${jsonEncode(report)}');

  expect(buildTimes.length, greaterThan(5));
  expect(uiSignificantlySlow, lessThanOrEqualTo(3));
  expect(rasterSignificantlySlow, lessThanOrEqualTo(3));
  expect(report['worst_frame_build_time_millis'] as num, lessThan(100));
  expect(report['worst_frame_rasterizer_time_millis'] as num, lessThan(100));
}
