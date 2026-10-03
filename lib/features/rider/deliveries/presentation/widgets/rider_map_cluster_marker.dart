import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_live_map_styles.dart';

/// Aggregated opportunity cluster marker that zooms in when clicked.
class RiderMapClusterMarker extends StatelessWidget {
  const RiderMapClusterMarker({
    required this.count,
    required this.onTap,
    super.key,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$count nearby delivery opportunities. Zoom in.',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const SizedBox.expand(
        child: Center(
          child: Icon(
            Icons.inventory_2_rounded,
            color: RiderLiveMapStyles.markerIconColor,
            size: RiderLiveMapStyles.clusterIconSize,
          ),
        ),
      ),
    ),
  );
}
