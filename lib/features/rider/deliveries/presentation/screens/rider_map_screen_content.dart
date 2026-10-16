part of 'rider_map_screen.dart';

extension _RiderMapScreenContent on _RiderMapScreenState {
  Widget _buildMapScreen(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([
      _locationController,
      widget.deliveryController,
      _routeController,
      if (widget.availabilityController != null) widget.availabilityController!,
    ]),
    builder: (context, _) => RiderMapContent(
      controller: _locationController,
      mapController: _mapController,
      requests: widget.deliveryController.requests,
      farms: _nearbyFarms,
      roadAccessConnections: _roadAccessConnections,
      farmDiscoveryError: _farmDiscoveryError,
      farmsLoading: _farmSearchLoading,
      routeController: _routeController,
      riderId: widget.profile?.id,
      filter: _filter,
      visibility: _visibility,
      onVisibilityChanged: (value) =>
          _updateMapState(() => _visibility = value),
      online: widget.availabilityController?.availability.isOnline,
      onOnlineChanged: widget.availabilityController == null
          ? null
          : _setMapOnline,
      onOpenNotifications: widget.onOpenNotifications,
      unreadNotifications: widget.unreadNotifications,
      onOpenDelivery: _openMapDelivery,
      onMessage: widget.onOpenConversation == null
          ? null
          : _openMapConversation,
      statusFor: widget.deliveryController.statusFor,
      mapZoom: _mapZoom,
      discoveryRadiusKm:
          widget.profile?.serviceRadiusKm ??
          RiderDeliverySearch.defaultRadiusKm,
      navigationActive: _navigationActive,
      onFilterChanged: _changeMapFilter,
      onMarkerTap: (request, kind) => unawaited(_openMarker(request, kind)),
      onFarmTap: (farm) => unawaited(_openFarm(farm)),
      onNavigateActive: (request) => unawaited(_startNavigation(request)),
      onExitNavigation: _exitNavigation,
      onRecenter: _recenter,
      onRefresh: () => unawaited(_refreshMapDiscovery()),
      onOpenList: widget.onOpenList,
      onMapReady: _onMapReady,
      onPositionChanged: _onPositionChanged,
    ),
  );

  Future<void> _setMapOnline(bool online) async {
    final result = await widget.availabilityController?.setOnline(online);
    if (!mounted || result == null || result.isSuccess) return;
    _showMapMessage(
      'Work status could not be changed. Review the status on Home.',
    );
  }

  void _openMapDelivery(DeliveryRequest request) {
    final riderId = widget.profile?.id;
    if (riderId == null || !request.isAssignedTo(riderId)) return;
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => RiderDeliveryDetailsScreen(
          request: request,
          controller: widget.deliveryController,
          riderId: riderId,
          locationController: _locationController,
          onOpenConversation: widget.onOpenConversation,
        ),
      ),
    );
  }

  Future<void> _openMapConversation(DeliveryRequest request) async {
    final opened = await widget.onOpenConversation?.call(request.id) ?? false;
    if (mounted && !opened)
      _showMapMessage('No delivery conversation is available yet.');
  }
}
