import 'package:flutter/material.dart';
import '../styles/rider_map_progress_styles.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_map_design_styles.dart';

import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_live_map_styles.dart';

/// Interactive or informational icon marker rendered on the rider map.
class RiderMapIconMarker extends StatelessWidget {
  const RiderMapIconMarker({
    required this.icon,
    required this.label,
    this.caption,
    this.prominent = false,
    this.offset = Offset.zero,
    this.tapExtent = RiderLiveMapStyles.standardMarkerExtent,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? caption;
  final bool prominent;
  final Offset offset;
  final double tapExtent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isRiderPuck =
        icon == Icons.navigation_rounded || icon == Icons.navigation;

    final Widget markerBody;
    if (isRiderPuck) {
      markerBody = SizedBox(
        width: RiderLiveMapStyles.radarRadius,
        height: RiderLiveMapStyles.radarRadius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: RiderLiveMapStyles.radarRadius,
              height: RiderLiveMapStyles.radarRadius,
              decoration: RiderMapProgressStyles.radar,
            ),
            Container(
              width: 36,
              height: 36,
              decoration: RiderMapDesignStyles.riderMarker,
              child: const Icon(
                Icons.navigation_rounded,
                color: AgrisellColors.surface,
                size: 20,
              ),
            ),
          ],
        ),
      );
    } else {
      markerBody = Container(
        width: 38,
        height: 38,
        decoration: RiderMapDesignStyles.markerFor(icon),
        child: Icon(
          icon,
          color: AgrisellColors.surface,
          size: prominent
              ? RiderLiveMapStyles.prominentIconSize
              : RiderLiveMapStyles.standardIconSize,
        ),
      );
    }

    final visual = SizedBox.square(
      dimension: tapExtent,
      child: Center(child: markerBody),
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
