import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/utils/map_coordinates.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_map_canvas.dart';

class ShippingAddressMapEditorScreen extends StatefulWidget {
  const ShippingAddressMapEditorScreen({
    required this.initialAddress,
    required this.latitude,
    required this.longitude,
    super.key,
  });

  final String initialAddress;
  final double? latitude;
  final double? longitude;

  @override
  State<ShippingAddressMapEditorScreen> createState() =>
      _ShippingAddressMapEditorScreenState();
}

class _ShippingAddressMapEditorScreenState
    extends State<ShippingAddressMapEditorScreen> {
  static const _fallback = LatLng(12.8797, 121.7740);
  final _mapController = MapController();
  late LatLng _point;
  var _loadingLocation = false;
  var _confirming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _point =
        MapCoordinates.isValid(
          latitude: widget.latitude,
          longitude: widget.longitude,
        )
        ? LatLng(widget.latitude!, widget.longitude!)
        : _fallback;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
      _error = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Turn on location services and try again.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is required to use your GPS location.',
        );
      }
      final position = await Geolocator.getCurrentPosition();
      final point = LatLng(position.latitude, position.longitude);
      if (!MapCoordinates.isValid(
        latitude: point.latitude,
        longitude: point.longitude,
      )) {
        throw Exception('GPS returned an invalid location. Try again.');
      }
      _moveTo(point, 17);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _moveTo(LatLng point, double zoom) {
    if (!MapCoordinates.isValid(
      latitude: point.latitude,
      longitude: point.longitude,
    )) {
      return;
    }
    setState(() => _point = point);
    _mapController.move(point, zoom.isFinite ? zoom.clamp(3, 19) : 16);
  }

  Future<void> _confirm() async {
    setState(() {
      _confirming = true;
      _error = null;
    });
    if (!MapCoordinates.isValid(
      latitude: _point.latitude,
      longitude: _point.longitude,
    )) {
      setState(() {
        _confirming = false;
        _error = 'The selected map location is invalid. Try again.';
      });
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop(
      BuyerShippingAddress(
        address: widget.initialAddress,
        latitude: _point.latitude,
        longitude: _point.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit address')),
    body: ShippingAddressMapCanvas(
      mapController: _mapController,
      point: _point,
      initialAddress: widget.initialAddress,
      hasInitialLocation: widget.latitude != null,
      loadingLocation: _loadingLocation,
      error: _error,
      onMapMoved: (point) {
        if (MapCoordinates.isValid(
          latitude: point.latitude,
          longitude: point.longitude,
        )) {
          setState(() => _point = point);
        }
      },
      onZoom: (change) => _moveTo(_point, _mapController.camera.zoom + change),
      onUseCurrentLocation: _useCurrentLocation,
    ),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: SizedBox(
        height: 40,
        child: FilledButton(
          onPressed: _confirming ? null : _confirm,
          child: Text(_confirming ? 'Confirming...' : 'Confirm'),
        ),
      ),
    ),
  );
}
