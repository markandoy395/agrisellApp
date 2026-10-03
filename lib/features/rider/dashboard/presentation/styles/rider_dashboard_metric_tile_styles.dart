import 'package:flutter/material.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_dashboard_metrics_styles.dart';

abstract final class RiderDashboardMetricTileStyles {
  static BoxDecoration containerDecoration(Color data_backgroundColor) =>
      BoxDecoration(
        color: data_backgroundColor,
        borderRadius: RiderDashboardMetricsStyles.tileRadius,
      );
}
