import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_live_map_styles.dart';

/// Interactive or informational icon marker rendered on the rider map.
class RiderMapIconMarker extends StatelessWidget {
  const RiderMapIconMarker({
    required this.icon,
    required this.label,
    this.prominent = false,
    this.offset = Offset.zero,
    this.tapExtent = RiderLiveMapStyles.standardMarkerExtent,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool prominent;
  final Offset offset;
  final double tapExtent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final visual = SizedBox.square(
      dimension: tapExtent,
      child: Center(
        child: Icon(
          icon,
          color: RiderLiveMapStyles.markerIconColor,
          size: prominent
              ? RiderLiveMapStyles.prominentIconSize
              : RiderLiveMapStyles.standardIconSize,
        ),
      ),
    );

    final interactive = onTap == null
        ? IgnorePointer(child: visual)
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: visual,
          );

    return Semantics(
      button: onTap != null,
      label: label,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [Transform.translate(offset: offset, child: interactive)],
        ),
      ),
    );
  }
}
