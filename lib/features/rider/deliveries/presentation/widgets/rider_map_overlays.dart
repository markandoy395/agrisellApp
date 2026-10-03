import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_map_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_active_delivery_card.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_toolbar.dart';

/// Top overlay for the rider map containing toolbar, filter chips,
/// discovery error banners, and the active delivery card.
class RiderMapTopOverlay extends StatelessWidget {
  const RiderMapTopOverlay({
    required this.discoveryRadiusKm,
    required this.farmsLoading,
    required this.filter,
    required this.farmDiscoveryError,
    required this.activeRequest,
    required this.navigationActive,
    required this.onOpenList,
    required this.onRefresh,
    required this.onFilterChanged,
    required this.onNavigateActive,
    super.key,
  });

  final double discoveryRadiusKm;
  final bool farmsLoading;
  final RiderMapFilter filter;
  final String? farmDiscoveryError;
  final DeliveryRequest? activeRequest;
  final bool navigationActive;
  final VoidCallback onOpenList;
  final VoidCallback onRefresh;
  final ValueChanged<RiderMapFilter> onFilterChanged;
  final VoidCallback onNavigateActive;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Column(
      children: [
        RiderMapToolbar(
          radiusKm: discoveryRadiusKm,
          onOpenList: onOpenList,
          onRefresh: onRefresh,
          loading: farmsLoading,
        ),
        const SizedBox(height: RiderMapStyles.overlaySpacing),
        RiderMapFilters(selected: filter, onChanged: onFilterChanged),
        if (farmDiscoveryError != null) ...[
          const SizedBox(height: RiderMapStyles.overlaySpacing),
          RiderMapDiscoveryError(
            message: farmDiscoveryError!,
            onRetry: onRefresh,
          ),
        ],
        if (activeRequest != null && !navigationActive) ...[
          const SizedBox(height: RiderMapStyles.overlaySpacing),
          RiderActiveDeliveryCard(
            request: activeRequest!,
            onNavigate: onNavigateActive,
          ),
        ],
      ],
    ),
  );
}

/// Horizontal scrollable chips for selecting map layer filters.
class RiderMapFilters extends StatelessWidget {
  const RiderMapFilters({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final RiderMapFilter selected;
  final ValueChanged<RiderMapFilter> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: RiderMapStyles.filterRowHeight,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            for (final value in RiderMapFilter.values) ...[
              FilterChip(
                selected: value == selected,
                showCheckmark: false,
                avatar: Icon(
                  value.icon,
                  key: ValueKey('rider-map-filter-${value.name}-icon'),
                  color: AgrisellColors.brandBlack,
                  size: RiderMapStyles.chipIconSize,
                ),
                label: Text(value.label),
                onSelected: (_) => onChanged(value),
                backgroundColor: RiderMapStyles.chipBackground,
                selectedColor: RiderMapStyles.chipBackground,
                labelStyle: RiderMapStyles.chipLabel,
                side: BorderSide.none,
                elevation: RiderMapStyles.filterChipElevation,
              ),
              if (value != RiderMapFilter.values.last)
                const SizedBox(width: RiderMapStyles.chipSpacing),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Inline error banner when farm discovery fails, with a retry button.
class RiderMapDiscoveryError extends StatelessWidget {
  const RiderMapDiscoveryError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Material(
    color: RiderMapStyles.errorBackground,
    borderRadius: RiderMapStyles.errorRadius,
    child: Padding(
      padding: RiderMapStyles.errorPadding,
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: RiderMapStyles.errorIconSize,
            color: AgrisellColors.statusOrangeText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: RiderMapStyles.errorText,
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
