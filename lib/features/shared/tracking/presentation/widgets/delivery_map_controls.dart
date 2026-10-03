import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

import '../styles/delivery_live_map_styles.dart';

class DeliveryMapControls extends StatelessWidget {
  const DeliveryMapControls({
    required this.onFitRoute,
    required this.hasRiderCoordinates,
    required this.followRider,
    required this.isRefreshing,
    this.onToggleFollowRider,
    this.onRefresh,
    super.key,
  });
  final VoidCallback onFitRoute;
  final bool hasRiderCoordinates;
  final bool followRider;
  final bool isRefreshing;
  final ValueChanged<bool>? onToggleFollowRider;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _MapActionButton(icon: Icons.route_rounded, onPressed: onFitRoute),
      const SizedBox(height: 8),
      if (onToggleFollowRider != null && hasRiderCoordinates)
        _MapActionButton(
          icon: followRider
              ? Icons.my_location_rounded
              : Icons.location_searching_rounded,
          isActive: followRider,
          onPressed: () => onToggleFollowRider!(!followRider),
        ),
      const SizedBox(height: 8),
      if (onRefresh != null)
        _MapActionButton(
          icon: Icons.refresh_rounded,
          isLoading: isRefreshing,
          onPressed: onRefresh!,
        ),
    ],
  );
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.isLoading = false,
  });
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Material(
    color: DeliveryLiveMapStyles.actionBackground(isActive),
    borderRadius: DeliveryLiveMapStyles.actionRadius,
    elevation: 3,
    shadowColor: Colors.black26,
    child: InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: DeliveryLiveMapStyles.actionRadius,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AgrisellColors.authGreen,
                  ),
                )
              : Icon(
                  icon,
                  size: 20,
                  color: DeliveryLiveMapStyles.actionIcon(isActive),
                ),
        ),
      ),
    ),
  );
}
