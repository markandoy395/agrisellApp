import 'package:flutter/material.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_dashboard_metrics_styles.dart';

abstract final class RiderDashboardMetricsCardsStyles {
  static final containerDecoration = BoxDecoration(
    color: RiderDashboardMetricsStyles.earningsBoxColor,
    borderRadius: RiderDashboardMetricsStyles.earningsIconBoxRadius,
  );
}
