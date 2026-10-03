import 'package:flutter/material.dart';

import '../styles/rider_active_delivery_summary_styles.dart';

class RiderDeliveryRouteStop extends StatelessWidget {
  const RiderDeliveryRouteStop({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: RiderActiveDeliverySummaryStyles.routeStopBoxSize,
        height: RiderActiveDeliverySummaryStyles.routeStopBoxSize,
        alignment: Alignment.center,
        decoration:
            RiderActiveDeliverySummaryStyles.routeStopIconBoxDecoration,
        child: Icon(
          icon,
          size: RiderActiveDeliverySummaryStyles.routeStopIconSize,
          color: RiderActiveDeliverySummaryStyles.routeStopIconColor,
        ),
      ),
      RiderActiveDeliverySummaryStyles.spacingRouteStopIcon,
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: RiderActiveDeliverySummaryStyles.routeStopLabelStyle,
            ),
            RiderActiveDeliverySummaryStyles.spacingRouteStopTexts,
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: RiderActiveDeliverySummaryStyles.routeStopValueStyle,
            ),
          ],
        ),
      ),
    ],
  );
}
