import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_road_access.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/rider_map_camera_policy.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_unavailable_card.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_route_panel.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderMapContent extends StatelessWidget {
  const RiderMapContent({
    required this.controller,
    required this.mapController,
    required this.requests,
    required this.farms,
    required this.roadAccessConnections,
    required this.farmDiscoveryError,
    required this.farmsLoading,
    required this.routeController,
    required this.riderId,
    required this.filter,
    required this.mapZoom,
    required this.discoveryRadiusKm,
    required this.navigationActive,
    required this.onFilterChanged,
    required this.onMarkerTap,
    required this.onFarmTap,
    required this.onNavigateActive,
    required this.onExitNavigation,
    required this.onRecenter,
    required this.onRefresh,
    required this.onOpenList,
    required this.onMapReady,
    required this.onPositionChanged,
    super.key,
  });

  final RiderLocationController controller;
  final MapController mapController;
  final List<DeliveryRequest> requests;
  final List<RiderNearbyFarm> farms;
  final List<RiderRoadAccessConnection> roadAccessConnections;
  final String? farmDiscoveryError;
  final bool farmsLoading;
  final RiderRouteController routeController;
  final String? riderId;
  final RiderMapFilter filter;
  final double mapZoom;
  final double discoveryRadiusKm;
  final bool navigationActive;
  final ValueChanged<RiderMapFilter> onFilterChanged;
  final RiderMapMarkerCallback onMarkerTap;
  final ValueChanged<RiderNearbyFarm> onFarmTap;
  final ValueChanged<DeliveryRequest> onNavigateActive;
  final VoidCallback onExitNavigation;
  final VoidCallback onRecenter;
  final VoidCallback onRefresh;
  final VoidCallback onOpenList;
  final VoidCallback onMapReady;
  final PositionCallback onPositionChanged;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    if (state == RiderLocationState.loading ||
        state == RiderLocationState.idle) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: RiderLoadingStateCard(
          title: 'Finding your location',
          message: 'Requesting the current device location.',
        ),
      );
    }
    final location = controller.location;
    if ((state == RiderLocationState.ready ||
            state == RiderLocationState.approximateLocation) &&
        location != null) {
      final displayedPoint = routeController.displayPoint(location);
      final riderPoint =
          RiderMapCameraPolicy.isCoordinateValid(
            displayedPoint.latitude,
            displayedPoint.longitude,
          )
          ? displayedPoint
          : DeliveryRoutePoint(
              latitude: location.latitude,
              longitude: location.longitude,
            );
      final active = requests
          .where(
            (request) =>
                riderId != null &&
                request.isAssignedTo(riderId!) &&
                !request.stage.isTerminal,
          )
          .firstOrNull;
      return Stack(
        children: [
          Positioned.fill(
            child: RiderLiveMap(
              riderPoint: riderPoint,
              routes: navigationActive ? routeController.routes : const [],
              activeRoute: navigationActive
                  ? routeController.activeRoute
                  : null,
              requests: requests,
              farms: farms,
              roadAccessConnections: roadAccessConnections,
              mapController: mapController,
              riderId: riderId,
              filter: filter,
              mapZoom: mapZoom,
              discoveryRadiusKm: discoveryRadiusKm,
              onMarkerTap: onMarkerTap,
              onFarmTap: onFarmTap,
              onMapReady: onMapReady,
              onPositionChanged: onPositionChanged,
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _MapToolbar(
                    radiusKm: discoveryRadiusKm,
                    onOpenList: onOpenList,
                    onRefresh: onRefresh,
                    loading: farmsLoading,
                  ),
                  const SizedBox(height: 8),
                  _MapFilters(selected: filter, onChanged: onFilterChanged),
                  if (farmDiscoveryError != null) ...[
                    const SizedBox(height: 8),
                    _MapDiscoveryError(
                      message: farmDiscoveryError!,
                      onRetry: onRefresh,
                    ),
                  ],
                  if (active != null && !navigationActive) ...[
                    const SizedBox(height: 8),
                    _ActiveDeliveryCard(
                      request: active,
                      onNavigate: () => onNavigateActive(active),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: navigationActive ? 258 : 104,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'rider-map-zoom-in',
                  tooltip: 'Zoom in',
                  onPressed: () {
                    final camera = mapController.camera;
                    if (!RiderMapCameraPolicy.canMoveCamera(camera)) return;
                    mapController.move(
                      camera.center,
                      RiderMapCameraPolicy.safeZoom(camera.zoom + 1),
                    );
                  },
                  backgroundColor: AgrisellColors.surface,
                  foregroundColor: AgrisellColors.authGreen,
                  child: const Icon(Icons.add_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'rider-map-zoom-out',
                  tooltip: 'Zoom out',
                  onPressed: () {
                    final camera = mapController.camera;
                    if (!RiderMapCameraPolicy.canMoveCamera(camera)) return;
                    mapController.move(
                      camera.center,
                      RiderMapCameraPolicy.safeZoom(camera.zoom - 1),
                    );
                  },
                  backgroundColor: AgrisellColors.surface,
                  foregroundColor: AgrisellColors.authGreen,
                  child: const Icon(Icons.remove_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'rider-map-recenter',
                  tooltip: 'Follow current location',
                  onPressed: onRecenter,
                  backgroundColor: AgrisellColors.surface,
                  foregroundColor: AgrisellColors.authGreen,
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),
          if (navigationActive)
            Positioned(
              left: 12,
              right: 12,
              bottom: 92,
              child: RiderRoutePanel(
                controller: routeController,
                requests: requests,
                location: location,
                locationController: controller,
                showRequestPicker: false,
                onExitNavigation: onExitNavigation,
              ),
            ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.all(14),
      child: RiderMapUnavailableCard(
        title: _titleFor(state),
        message: controller.errorMessage ?? _messageFor(state),
        primaryActionLabel: _primaryLabel(controller, state),
        onPrimaryAction: _primaryAction(controller, state),
      ),
    );
  }

  String _titleFor(RiderLocationState state) => switch (state) {
    RiderLocationState.serviceDisabled => 'Location services are off',
    RiderLocationState.permissionDenied => 'Location permission is needed',
    RiderLocationState.permissionDeniedForever =>
      'Location permission is blocked',
    RiderLocationState.approximateLocation => 'Precise location is off',
    _ => 'Map location unavailable',
  };

  String _messageFor(RiderLocationState state) => switch (state) {
    RiderLocationState.serviceDisabled =>
      'Enable device location to display live pickup and delivery routes.',
    RiderLocationState.permissionDenied =>
      'Allow location access to show your position and nearby pickup requests.',
    RiderLocationState.permissionDeniedForever =>
      'Open app settings to grant location access for rider navigation.',
    RiderLocationState.approximateLocation =>
      'Enable precise location before using arrival actions.',
    _ => 'Try refreshing your device location.',
  };

  String _primaryLabel(
    RiderLocationController controller,
    RiderLocationState state,
  ) =>
      controller.supportsDeviceSettings &&
          (state == RiderLocationState.serviceDisabled ||
              state == RiderLocationState.permissionDeniedForever ||
              state == RiderLocationState.approximateLocation)
      ? 'Open settings'
      : state == RiderLocationState.permissionDenied
      ? 'Allow location'
      : 'Try again';

  VoidCallback _primaryAction(
    RiderLocationController controller,
    RiderLocationState state,
  ) {
    final action = switch (state) {
      RiderLocationState.serviceDisabled => controller.openLocationSettings,
      RiderLocationState.permissionDeniedForever => controller.openAppSettings,
      RiderLocationState.approximateLocation => controller.openAppSettings,
      _ => null,
    };
    return controller.supportsDeviceSettings && action != null
        ? () => unawaited(action())
        : state == RiderLocationState.permissionDenied
        ? () => unawaited(controller.refresh(requestPermission: true))
        : controller.refresh;
  }
}

class _MapToolbar extends StatelessWidget {
  const _MapToolbar({
    required this.radiusKm,
    required this.onOpenList,
    required this.onRefresh,
    required this.loading,
  });

  final double radiusKm;
  final VoidCallback onOpenList;
  final VoidCallback onRefresh;
  final bool loading;

  @override
  Widget build(BuildContext context) => Material(
    color: AgrisellColors.surface.withValues(alpha: 0.94),
    elevation: 3,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.only(left: 14, right: 4),
      child: Row(
        children: [
          const Icon(Icons.map_rounded, color: AgrisellColors.authGreen),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rider map',
                  style: TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Live GPS · ${radiusKm.toStringAsFixed(0)} km service radius',
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                  ),
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
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.gps_fixed_rounded),
          ),
        ],
      ),
    ),
  );
}

class _MapDiscoveryError extends StatelessWidget {
  const _MapDiscoveryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Material(
    color: AgrisellColors.statusOrangeBackground.withValues(alpha: 0.96),
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 7, 6, 7),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: AgrisellColors.statusOrangeText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AgrisellColors.statusOrangeText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

class _MapFilters extends StatelessWidget {
  const _MapFilters({required this.selected, required this.onChanged});
  final RiderMapFilter selected;
  final ValueChanged<RiderMapFilter> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 39,
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
                  size: 17,
                ),
                label: Text(value.label),
                onSelected: (_) => onChanged(value),
                backgroundColor: AgrisellColors.surface.withValues(alpha: 0.94),
                selectedColor: AgrisellColors.surface.withValues(alpha: 0.94),
                labelStyle: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide.none,
                elevation: 2,
              ),
              if (value != RiderMapFilter.values.last) const SizedBox(width: 7),
            ],
          ],
        ),
      ),
    ),
  );
}

class _ActiveDeliveryCard extends StatelessWidget {
  const _ActiveDeliveryCard({required this.request, required this.onNavigate});
  final DeliveryRequest request;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Material(
      color: AgrisellColors.surface.withValues(alpha: 0.96),
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AgrisellColors.statusOrangeBackground,
              foregroundColor: AgrisellColors.statusOrangeText,
              child: Icon(Icons.local_shipping_rounded, size: 20),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACTIVE DELIVERY',
                    style: TextStyle(
                      color: AgrisellColors.statusOrangeText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    request.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (constraints.maxWidth < 430)
              IconButton.filled(
                tooltip: request.stage.isDeliveryLeg
                    ? 'Navigate to delivery'
                    : 'Navigate to pickup',
                onPressed: onNavigate,
                icon: const Icon(Icons.navigation_rounded),
              )
            else
              FilledButton.icon(
                onPressed: onNavigate,
                icon: const Icon(Icons.navigation_rounded, size: 17),
                label: Text(
                  request.stage.isDeliveryLeg
                      ? 'Navigate to delivery'
                      : 'Navigate to pickup',
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
