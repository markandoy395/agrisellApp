import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_map_styles.dart';

/// Floating toolbar displaying map title, GPS radius, and quick actions.
class RiderMapToolbar extends StatelessWidget {
  const RiderMapToolbar({
    required this.radiusKm,
    required this.onOpenList,
    required this.onRefresh,
    required this.loading,
    super.key,
  });

  final double radiusKm;
  final VoidCallback onOpenList;
  final VoidCallback onRefresh;
  final bool loading;

  @override
  Widget build(BuildContext context) => Material(
    color: RiderMapStyles.toolbarBackground,
    elevation: RiderMapStyles.toolbarElevation,
    borderRadius: RiderMapStyles.toolbarRadius,
    child: Padding(
      padding: RiderMapStyles.toolbarPadding,
      child: Row(
        children: [
          const Icon(Icons.map_rounded, color: AgrisellColors.authGreen),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rider map', style: RiderMapStyles.toolbarTitle),
                Text(
                  'Live GPS · ${radiusKm.toStringAsFixed(0)} km service radius',
                  style: RiderMapStyles.toolbarSubtitle,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delivery list',
            onPressed: onOpenList,
            icon: const Icon(Icons.view_list_rounded),
          ),
          IconButton(
            tooltip: 'Refresh location',
            onPressed: loading ? null : onRefresh,
            icon: loading
                ? const SizedBox.square(
                    dimension: RiderMapStyles.spinnerDimension,
                    child: CircularProgressIndicator(
                      strokeWidth: RiderMapStyles.spinnerStrokeWidth,
                    ),
                  )
                : const Icon(Icons.gps_fixed_rounded),
          ),
        ],
      ),
    ),
  );
}
