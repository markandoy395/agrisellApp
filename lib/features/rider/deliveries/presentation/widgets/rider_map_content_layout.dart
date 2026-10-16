part of 'rider_map_content.dart';

extension _RiderMapContentLayout on RiderMapContent {
  Widget _buildMap(BuildContext context) {
    final location = controller.location;
    final ready =
        (controller.state == RiderLocationState.ready ||
            controller.state == RiderLocationState.approximateLocation) &&
        location != null;
    final owned = requests
        .where(
          (request) =>
              riderId != null &&
              request.isAssignedTo(riderId!) &&
              !request.stage.isTerminal,
        )
        .toList();
    final selected = owned
        .where((item) => item.id == routeController.selectedRequestId)
        .firstOrNull;
    final active = selected ?? owned.firstOrNull;
    return Column(
      children: [
        if (navigationActive)
          RiderMapManeuverBanner(
            controller: routeController,
            onExit: onExitNavigation,
          )
        else
          RiderMapToolbar(
            radiusKm: discoveryRadiusKm,
            onOpenList: onOpenList,
            onRefresh: onRefresh,
            loading: farmsLoading,
            onOpenNotifications: onOpenNotifications,
            unreadNotifications: unreadNotifications,
          ),
        Expanded(
          child: !ready
              ? RiderMapLocationFallback(controller: controller)
              : Stack(
                  children: [
                    Positioned.fill(
                      child: RiderLiveMap(
                        riderPoint: _riderPoint(location),
                        routes: navigationActive
                            ? routeController.routes
                            : const [],
                        activeRoute: navigationActive
                            ? routeController.activeRoute
                            : null,
                        requests: requests,
                        farms: farms,
                        roadAccessConnections: roadAccessConnections,
                        mapController: mapController,
                        riderId: riderId,
                        filter: filter,
                        visibility: visibility,
                        mapZoom: mapZoom,
                        discoveryRadiusKm: discoveryRadiusKm,
                        onMarkerTap: onMarkerTap,
                        onFarmTap: onFarmTap,
                        onMapReady: onMapReady,
                        onPositionChanged: onPositionChanged,
                      ),
                    ),
                    if (!navigationActive)
                      Positioned(
                        left: 12,
                        top: 12,
                        child: RiderMapStatusControl(
                          online: online,
                          onChanged: onOnlineChanged,
                          onRefresh: onRefresh,
                        ),
                      ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: RiderMapFloatingControls(
                        navigationActive: navigationActive,
                        onRecenter: onRecenter,
                        onOptions: () => showRiderMapOptions(
                          context,
                          visibility: visibility,
                          onChanged: onVisibilityChanged ?? (_) {},
                          filter: filter,
                          onFilterChanged: onFilterChanged,
                        ),
                      ),
                    ),
                    if (navigationActive)
                      RiderMapNavigationSheet(
                        routeController: routeController,
                        locationController: controller,
                        requests: requests,
                        request: active,
                        status: active == null ? null : statusFor?.call(active),
                        onExit: onExitNavigation,
                        onOpenDelivery: () {
                          if (active != null) onOpenDelivery?.call(active);
                        },
                        onMessage: active == null || onMessage == null
                            ? null
                            : () => onMessage!(active),
                      ),
                    if (!navigationActive)
                      RiderMapDiscoverySheet(
                        requests: requests,
                        farms: farms,
                        active: active,
                        onRequestTap: (request) => onMarkerTap(
                          request,
                          RiderMapMarkerKind.availableDelivery,
                        ),
                        onFarmTap: onFarmTap,
                        onNavigate: () {
                          if (active != null) onNavigateActive(active);
                        },
                        onOpenList: onOpenList,
                        onRefresh: onRefresh,
                        farmError: farmDiscoveryError,
                        farmsLoading: farmsLoading,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  DeliveryRoutePoint _riderPoint(RiderDeviceLocation location) {
    final point = routeController.displayPoint(location);
    return RiderMapCameraPolicy.isCoordinateValid(
          point.latitude,
          point.longitude,
        )
        ? point
        : DeliveryRoutePoint(
            latitude: location.latitude,
            longitude: location.longitude,
          );
  }
}

