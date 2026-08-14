import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/utils/written_address.dart';
import 'package:agresell_app/core/utils/map_coordinates.dart';
import 'package:agresell_app/features/shared/location/data/confirmed_location_repository.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/presentation/controllers/gps_selection_controller.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/location_selector_layout.dart';

part 'location_selector_restore.dart';

class LocationSelectorSheet extends StatefulWidget {
  const LocationSelectorSheet({
    required this.role,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
    this.showAddressFields = true,
    this.repository,
    this.gpsController,
    super.key,
  });

  final LocationOwnerRole role;
  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;
  final bool showAddressFields;
  final ConfirmedLocationRepository? repository;
  final GpsSelectionController? gpsController;

  @override
  State<LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends State<LocationSelectorSheet> {
  static const _fallback = LatLng(12.8797, 121.7740);
  late final ConfirmedLocationRepository _repository;
  late final GpsSelectionController _gps;
  late final MapController _mapController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  final _mapKey = GlobalKey();
  LatLng _selected = _fallback;
  ConfirmedLocation? _cached;
  DateTime? _lastGpsTime;
  var _centerPinMode = true;
  var _userAdjusted = false;
  var _offlineTiles = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ConfirmedLocationRepository();
    _gps = widget.gpsController ?? GpsSelectionController();
    _mapController = MapController();
    if (MapCoordinates.isValid(
      latitude: widget.initialLatitude,
      longitude: widget.initialLongitude,
    )) {
      _selected = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _userAdjusted = true;
    }
    _addressController = TextEditingController(
      text: _requiresWrittenAddress
          ? WrittenAddress.valueOrNull(widget.initialAddress)
          : widget.initialAddress,
    );
    _addressController.addListener(_onAddressChanged);
    _notesController = TextEditingController();
    _gps.addListener(_onGpsChanged);
    unawaited(_restoreAndStart());
  }

  void _onGpsChanged() {
    if (!mounted) return;
    final position = _gps.bestPosition;
    if (position != null && position.timestamp != _lastGpsTime) {
      _lastGpsTime = position.timestamp;
      final point = LatLng(position.latitude, position.longitude);
      if (!_userAdjusted) {
        _selected = point;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => mounted ? _mapController.move(point, 17) : null,
        );
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _gps.removeListener(_onGpsChanged);
    if (widget.gpsController == null) {
      _gps.dispose();
    } else {
      unawaited(_gps.stop());
    }
    _mapController.dispose();
    _addressController.removeListener(_onAddressChanged);
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = _gps.bestPosition;
    final detected = position == null
        ? (_cached == null
              ? null
              : LatLng(_cached!.latitude, _cached!.longitude))
        : LatLng(position.latitude, position.longitude);
    final accuracy = position?.accuracy ?? _cached?.accuracyMeters;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .9,
      child: LocationSelectorLayout(
        centerPinMode: _centerPinMode,
        onModeChanged: (value) => setState(() => _centerPinMode = value),
        onClose: () => Navigator.pop(context),
        gpsController: _gps,
        offlineTiles: _offlineTiles,
        mapController: _mapController,
        selected: _selected,
        detected: detected,
        accuracyMeters: accuracy,
        onSelected: _select,
        onMapMoved: _select,
        onTileError: _markOffline,
        onZoom: _zoom,
        onUseCurrentLocation: _useCurrentLocation,
        mapKey: _mapKey,
        addressController: _addressController,
        notesController: _notesController,
        canConfirm:
            accuracy != null &&
            (!_requiresWrittenAddress ||
                WrittenAddress.isValid(_addressController.text)) &&
            (_gps.state == GpsSelectionState.ready ||
                _gps.state == GpsSelectionState.poorAccuracy ||
                _cached != null),
        saving: _saving,
        onConfirm: _confirm,
        requiresWrittenAddress: _requiresWrittenAddress,
        showAddressFields: widget.showAddressFields,
      ),
    );
  }

  void _select(LatLng point) => setState(() {
    _selected = point;
    _userAdjusted = true;
  });

  bool get _requiresWrittenAddress => widget.showAddressFields;

  void _onAddressChanged() {
    if (mounted) setState(() {});
  }

  void _refresh(VoidCallback update) => setState(update);

  void _markOffline() {
    if (_offlineTiles || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => mounted ? setState(() => _offlineTiles = true) : null,
    );
  }

  Future<void> _confirm() async {
    if (_requiresWrittenAddress &&
        !WrittenAddress.isValid(_addressController.text)) {
      return;
    }
    setState(() => _saving = true);
    await _gps.stop();
    final accuracy = _gps.bestPosition?.accuracy ?? _cached!.accuracyMeters;
    final location = ConfirmedLocation(
      latitude: _selected.latitude,
      longitude: _selected.longitude,
      accuracyMeters: accuracy,
      capturedAt: DateTime.now(),
      address: _emptyToNull(_addressController.text),
      notes: widget.showAddressFields
          ? _emptyToNull(_notesController.text)
          : null,
    );
    await _repository.confirm(widget.role, location);
    if (mounted) Navigator.pop(context, location);
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();
}
