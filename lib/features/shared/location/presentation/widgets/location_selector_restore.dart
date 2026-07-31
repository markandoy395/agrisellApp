part of 'location_selector_sheet.dart';

extension _LocationSelectorRestore on _LocationSelectorSheetState {
  Future<void> _restoreAndStart() async {
    final cached = await _repository.load(widget.role);
    if (cached != null && mounted) {
      final hasInitialLocation = MapCoordinates.isValid(
        latitude: widget.initialLatitude,
        longitude: widget.initialLongitude,
      );
      _refresh(() {
        _cached = cached;
        if (!hasInitialLocation) {
          _selected = LatLng(cached.latitude, cached.longitude);
        }
        if (_addressController.text.trim().isEmpty) {
          _addressController.text = _requiresWrittenAddress
              ? WrittenAddress.valueOrNull(cached.address) ?? ''
              : cached.address ?? '';
        }
        if (widget.showAddressFields) {
          _notesController.text = cached.notes ?? '';
        }
      });
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _mapController.move(_selected, 16),
      );
    }
    unawaited(_repository.syncPending(widget.role));
    await _gps.start();
  }

  void _zoom(double change) {
    final zoom = (_mapController.camera.zoom + change).clamp(3, 19).toDouble();
    _mapController.move(_selected, zoom);
  }

  void _useCurrentLocation() {
    final position = _gps.bestPosition;
    if (position == null) {
      _userAdjusted = false;
      unawaited(_gps.start());
      return;
    }
    final point = LatLng(position.latitude, position.longitude);
    _refresh(() {
      _selected = point;
      _userAdjusted = false;
    });
    _mapController.move(point, 17);
  }
}
