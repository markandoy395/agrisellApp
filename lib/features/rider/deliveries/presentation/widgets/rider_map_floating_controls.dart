import 'package:flutter/material.dart';
import '../styles/rider_map_design_styles.dart';

class RiderMapFloatingControls extends StatelessWidget {
  const RiderMapFloatingControls({
    required this.navigationActive,
    required this.onRecenter,
    required this.onOptions,
    this.onAltRoute,
    super.key,
  });

  final bool navigationActive;
  final VoidCallback onRecenter;
  final VoidCallback onOptions;
  final VoidCallback? onAltRoute;

  @override
  Widget build(BuildContext context) {
    if (navigationActive) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Voice guidance unavailable',
            style: RiderMapDesignStyles.control,
            onPressed: null,
            icon: const Icon(Icons.volume_off_rounded),
          ),
          const SizedBox(height: 8),
          IconButton(
            tooltip: 'Follow current location',
            style: RiderMapDesignStyles.control,
            onPressed: onRecenter,
            icon: const Icon(Icons.my_location_rounded),
          ),
          if (onAltRoute != null) ...[
            const SizedBox(height: 8),
            IconButton(
              tooltip: 'Alternate routes',
              style: RiderMapDesignStyles.control,
              onPressed: onAltRoute,
              icon: const Icon(Icons.alt_route_rounded),
            ),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Map options',
          style: RiderMapDesignStyles.control,
          onPressed: onOptions,
          icon: const Icon(Icons.layers_outlined),
        ),
        const SizedBox(height: 8),
        IconButton(
          tooltip: 'Follow current location',
          style: RiderMapDesignStyles.control,
          onPressed: onRecenter,
          icon: const Icon(Icons.my_location_rounded),
        ),
      ],
    );
  }
}
