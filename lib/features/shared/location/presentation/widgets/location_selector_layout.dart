import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/location/presentation/controllers/gps_selection_controller.dart';

import 'location_gps_status.dart';
import 'location_selector_controls.dart';
import 'location_selector_map.dart';

class LocationSelectorLayout extends StatelessWidget {
  const LocationSelectorLayout({
    required this.centerPinMode,
    required this.onModeChanged,
    required this.onClose,
    required this.gpsController,
    required this.offlineTiles,
    required this.mapController,
    required this.selected,
    required this.detected,
    required this.accuracyMeters,
    required this.onSelected,
    required this.onMapMoved,
    required this.onTileError,
    required this.onZoom,
    required this.onUseCurrentLocation,
    required this.mapKey,
    required this.addressController,
    required this.notesController,
    required this.canConfirm,
    required this.saving,
    required this.onConfirm,
    required this.requiresWrittenAddress,
    required this.showAddressFields,
    super.key,
  });

  final bool centerPinMode;
  final ValueChanged<bool> onModeChanged;
  final VoidCallback onClose;
  final GpsSelectionController gpsController;
  final bool offlineTiles;
  final MapController mapController;
  final LatLng selected;
  final LatLng? detected;
  final double? accuracyMeters;
  final ValueChanged<LatLng> onSelected;
  final ValueChanged<LatLng> onMapMoved;
  final VoidCallback onTileError;
  final ValueChanged<double> onZoom;
  final VoidCallback onUseCurrentLocation;
  final GlobalKey mapKey;
  final TextEditingController addressController;
  final TextEditingController notesController;
  final bool canConfirm;
  final bool saving;
  final VoidCallback onConfirm;
  final bool requiresWrittenAddress;
  final bool showAddressFields;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AgrisellColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          LocationSelectorHeader(
            centerPinMode: centerPinMode,
            onModeChanged: onModeChanged,
            onClose: onClose,
            showModeSwitch: showAddressFields,
          ),
          if (showAddressFields)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: LocationGpsStatus(controller: gpsController),
            ),
          if (offlineTiles)
            const MaterialBanner(
              content: Text(
                'No internet connection. GPS and cached map tiles still work.',
                style: TextStyle(fontSize: 12),
              ),
              actions: [SizedBox.shrink()],
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: LocationSelectorMap(
                  controller: mapController,
                  selected: selected,
                  detected: detected,
                  accuracyMeters: accuracyMeters,
                  centerPinMode: centerPinMode,
                  onSelected: onSelected,
                  onMapMoved: onMapMoved,
                  onTileError: onTileError,
                  onZoom: onZoom,
                  onUseCurrentLocation: onUseCurrentLocation,
                  locating:
                      gpsController.state ==
                          GpsSelectionState.requestingPermission ||
                      gpsController.state == GpsSelectionState.acquiring,
                  mapKey: mapKey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          LocationSelectorDetails(
            addressController: addressController,
            notesController: notesController,
            canConfirm: canConfirm,
            saving: saving,
            onConfirm: onConfirm,
            requiresWrittenAddress: requiresWrittenAddress,
            showFields: showAddressFields,
          ),
        ],
      ),
    );
  }
}
