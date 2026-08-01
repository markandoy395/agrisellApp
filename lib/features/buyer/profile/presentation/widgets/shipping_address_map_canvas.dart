import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class ShippingAddressMapCanvas extends StatelessWidget {
  const ShippingAddressMapCanvas({
    required this.mapController,
    required this.point,
    required this.initialAddress,
    required this.hasInitialLocation,
    required this.loadingLocation,
    required this.error,
    required this.onMapMoved,
    required this.onZoom,
    required this.onUseCurrentLocation,
    super.key,
  });

  final MapController mapController;
  final LatLng point;
  final String initialAddress;
  final bool hasInitialLocation;
  final bool loadingLocation;
  final String? error;
  final ValueChanged<LatLng> onMapMoved;
  final ValueChanged<double> onZoom;
  final VoidCallback onUseCurrentLocation;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: point,
          initialZoom: hasInitialLocation ? 16 : 5,
          onPositionChanged: (camera, hasGesture) {
            if (hasGesture) onMapMoved(camera.center);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.agrisell.agresell_app',
          ),
          const SimpleAttributionWidget(
            source: Text('OpenStreetMap contributors'),
          ),
        ],
      ),
      const Center(
        child: IgnorePointer(
          child: Padding(
            padding: EdgeInsets.only(bottom: 42),
            child: Icon(
              Icons.location_pin,
              color: AgrisellColors.statusRedText,
              size: 48,
            ),
          ),
        ),
      ),
      Positioned(
        top: 14,
        left: 16,
        right: 16,
        child: _AddressBubble(address: initialAddress),
      ),
      Positioned(
        right: 16,
        bottom: 98,
        child: _MapControls(
          loadingLocation: loadingLocation,
          onZoom: onZoom,
          onUseCurrentLocation: onUseCurrentLocation,
        ),
      ),
      if (error != null)
        Positioned(
          left: 16,
          right: 16,
          bottom: 68,
          child: _ErrorMessage(message: error!),
        ),
    ],
  );
}

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.loadingLocation,
    required this.onZoom,
    required this.onUseCurrentLocation,
  });
  final bool loadingLocation;
  final ValueChanged<double> onZoom;
  final VoidCallback onUseCurrentLocation;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      FloatingActionButton.small(
        heroTag: 'zoom-in',
        onPressed: () => onZoom(1),
        child: const Icon(Icons.add),
      ),
      const SizedBox(height: 8),
      FloatingActionButton.small(
        heroTag: 'zoom-out',
        onPressed: () => onZoom(-1),
        child: const Icon(Icons.remove),
      ),
      const SizedBox(height: 8),
      FloatingActionButton.small(
        heroTag: 'current-location',
        tooltip: 'Use my current location',
        onPressed: loadingLocation ? null : onUseCurrentLocation,
        child: loadingLocation
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location),
      ),
    ],
  );
}

class _AddressBubble extends StatelessWidget {
  const _AddressBubble({required this.address});
  final String address;
  @override
  Widget build(BuildContext context) => Material(
    borderRadius: BorderRadius.circular(14),
    color: AgrisellColors.surface,
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        address.isEmpty ? 'Move the map to place your delivery pin.' : address,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13),
      ),
    ),
  );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Material(
    color: AgrisellColors.statusRedBackground,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          color: AgrisellColors.statusRedText,
        ),
      ),
    ),
  );
}
