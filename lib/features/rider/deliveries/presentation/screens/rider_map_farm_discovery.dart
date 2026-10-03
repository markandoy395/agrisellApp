part of 'rider_map_screen.dart';

extension _RiderMapFarmDiscovery on _RiderMapScreenState {
  Future<void> _openFarm(RiderNearbyFarm farm) async {
    final riderId = widget.profile?.id;
    final hasActiveDelivery =
        riderId != null &&
        widget.deliveryController.requests.any(
          (request) =>
              request.isAssignedTo(riderId) && !request.stage.isTerminal,
        );
    final roadAccessSource = _roadAccessSourceForFarm(farm);
    _selectRoadAccessSource(roadAccessSource);
    final shouldNavigate = await showRiderMapFarmSheet(
      context,
      farm: farm,
      navigationBlockedByActiveDelivery: hasActiveDelivery,
    );
    if (!mounted) return;
    if (!shouldNavigate) {
      _clearRoadAccessSelection(roadAccessSource?.id);
      return;
    }
    final search = _lastNearbySearch;
    if (search == null) {
      _clearRoadAccessSelection(roadAccessSource?.id);
      _showMapMessage('Nearby farm information is still loading.');
      return;
    }
    try {
      final refreshed = await _mapDiscoveryRepository.fetchNearbyFarms(search);
      if (!mounted) return;
      final current = refreshed.where((item) => item.id == farm.id).firstOrNull;
      if (current == null) {
        _showMapMessage('This farm is no longer available on the map.');
        _clearRoadAccessSelection(roadAccessSource?.id);
        return;
      }
      _updateMapState(() => _nearbyFarms = refreshed);
      await _startFarmNavigation(current);
    } on RiderMapDiscoveryException catch (error) {
      if (!mounted) return;
      _clearRoadAccessSelection(roadAccessSource?.id);
      _showMapMessage(error.message);
    }
  }

  Future<void> _loadNearbyFarms(RiderDeliverySearch search) async {
    final generation = ++_farmSearchGeneration;
    _updateMapState(() {
      _farmSearchLoading = true;
      _farmDiscoveryError = null;
    });
    try {
      final farms = await _mapDiscoveryRepository.fetchNearbyFarms(search);
      if (!mounted || generation != _farmSearchGeneration) return;
      _updateMapState(() {
        _nearbyFarms = farms;
        _farmSearchLoading = false;
      });
      _scheduleRoadAccessSync();
    } on RiderMapDiscoveryException catch (error) {
      if (!mounted || generation != _farmSearchGeneration) return;
      _updateMapState(() {
        _nearbyFarms = const [];
        _farmSearchLoading = false;
        _farmDiscoveryError = error.message;
      });
    } catch (_) {
      if (!mounted || generation != _farmSearchGeneration) return;
      _updateMapState(() {
        _nearbyFarms = const [];
        _farmSearchLoading = false;
        _farmDiscoveryError = 'Nearby farmers could not be loaded.';
      });
    }
  }
}
