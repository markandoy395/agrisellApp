part of 'rider_map_screen.dart';

extension _RiderMapRoadAccessSelection on _RiderMapScreenState {
  void _replaceRoadAccessConnections(
    List<RiderRoadAccessConnection> connections,
  ) {
    if (!mounted) return;
    _updateMapState(
      () => _roadAccessConnections = List.unmodifiable(connections),
    );
  }

  void _selectRoadAccessSource(RiderRoadAccessSource? source) {
    _roadAccessDebounce?.cancel();
    _roadAccessGeneration++;
    _lastRoadAccessFingerprint = null;
    _lastRoadAccessAttempt = null;
    _updateMapState(() {
      _selectedRoadAccessSource = source;
      _roadAccessConnections = const [];
    });
    if (source != null) _scheduleRoadAccessSync();
  }

  void _clearRoadAccessSelection([String? expectedId]) {
    final selected = _selectedRoadAccessSource;
    if (selected == null || (expectedId != null && selected.id != expectedId)) {
      return;
    }
    _selectRoadAccessSource(null);
  }

  void _changeMapFilter(RiderMapFilter value) {
    if (_filter == value) return;
    _roadAccessDebounce?.cancel();
    _roadAccessGeneration++;
    _lastRoadAccessFingerprint = null;
    _lastRoadAccessAttempt = null;
    _updateMapState(() {
      _filter = value;
      _selectedRoadAccessSource = null;
      _roadAccessConnections = const [];
    });
  }
}
