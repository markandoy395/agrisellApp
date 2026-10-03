import 'package:flutter/material.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_active_delivery_summary_styles.dart';

abstract final class RiderNoActiveDeliveryCardStyles {
  static final containerDecoration = BoxDecoration(
    color: RiderActiveDeliverySummaryStyles.emptyBadgeBackground,
    borderRadius: RiderActiveDeliverySummaryStyles.iconBadgeRadius,
  );
}
