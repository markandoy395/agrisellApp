import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_map_marker_sheet_styles.dart';

class RiderMapMetricChip extends StatelessWidget {
  const RiderMapMetricChip({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: RiderMapMarkerSheetStyles.chipDecoration,
    child: Padding(
      padding: RiderMapMarkerSheetStyles.chipPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: RiderMapMarkerSheetStyles.chipIconColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: RiderMapMarkerSheetStyles.chipTextStyle,
          ),
        ],
      ),
    ),
  );
}

class RiderMapDetailRow extends StatelessWidget {
  const RiderMapDetailRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: RiderMapMarkerSheetStyles.detailRowPadding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: RiderMapMarkerSheetStyles.detailLabelWidth,
          child: Text(
            label,
            style: RiderMapMarkerSheetStyles.detailLabelTextStyle,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: RiderMapMarkerSheetStyles.detailValueTextStyle,
          ),
        ),
      ],
    ),
  );
}
