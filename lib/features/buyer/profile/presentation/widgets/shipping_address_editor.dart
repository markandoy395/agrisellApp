import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:agresell_app/core/utils/written_address.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_editor_content.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

class ShippingAddressEditor extends StatefulWidget {
  const ShippingAddressEditor({
    required this.onSave,
    this.initialAddress = '',
    this.fullName = '',
    this.phoneNumber = '',
    this.latitude,
    this.longitude,
    this.gpsGateway,
    super.key,
  });

  final Future<void> Function(BuyerShippingAddress address) onSave;
  final String initialAddress;
  final String fullName;
  final String phoneNumber;
  final double? latitude;
  final double? longitude;
  final GpsLocationGateway? gpsGateway;
  @override
  State<ShippingAddressEditor> createState() => _ShippingAddressEditorState();
}

class _ShippingAddressEditorState extends State<ShippingAddressEditor> {
  final _streetController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _barangayController = TextEditingController();
  final _postalCodeController = TextEditingController();
  late final GpsLocationGateway _gpsGateway;
  double? _latitude;
  double? _longitude;
  String? _error;
  var _isSaving = false;
  var _isCapturingLocation = false;
  @override
  void initState() {
    super.initState();
    _gpsGateway = widget.gpsGateway ?? GeolocatorGpsLocationGateway();
    _streetController.text = widget.initialAddress;
    _latitude = widget.latitude;
    _longitude = widget.longitude;
  }

  @override
  void dispose() {
    _streetController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _barangayController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  String get _address {
    final completeAddress = _streetController.text.trim();
    if (_isResolvedAddress(completeAddress)) return completeAddress;
    return [
      completeAddress,
      'Barangay ${_barangayController.text.trim()}',
      _cityController.text.trim(),
      _provinceController.text.trim(),
      _postalCodeController.text.trim(),
      'Philippines',
    ].where((value) => value.isNotEmpty).join(', ');
  }

  bool _isResolvedAddress(String value) =>
      value.toLowerCase().contains('philippines') ||
      value.split(',').length >= 4;

  bool get _isComplete =>
      _streetController.text.trim().isNotEmpty &&
      _provinceController.text.trim().isNotEmpty &&
      _cityController.text.trim().isNotEmpty &&
      _barangayController.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_isComplete || !WrittenAddress.isValid(_address)) {
      setState(
        () => _error = 'Complete your street, barangay, city, and province.',
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await _captureCurrentLocation();
      if (!mounted) return;
      await widget.onSave(
        BuyerShippingAddress(
          address: _address,
          latitude: _latitude,
          longitude: _longitude,
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _captureCurrentLocation() async {
    setState(() {
      _isCapturingLocation = true;
      _error = null;
    });
    try {
      if (!await _gpsGateway.isServiceEnabled()) {
        await _gpsGateway.openLocationSettings();
        throw Exception('Turn on location services, then try saving again.');
      }
      var permission = await _gpsGateway.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _gpsGateway.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Allow location access so we can capture your delivery location.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        await _gpsGateway.openAppSettings();
        throw Exception(
          'Allow location permission in app settings, then try saving again.',
        );
      }
      if (await _gpsGateway.getAccuracyStatus() ==
          LocationAccuracyStatus.reduced) {
        await _gpsGateway.openAppSettings();
        throw Exception('Enable precise location, then try saving again.');
      }
      final position = await _gpsGateway.currentPosition(
        settings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _latitude = position.latitude;
      _longitude = position.longitude;
    } finally {
      if (mounted) setState(() => _isCapturingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) => ShippingAddressEditorContent(
    streetController: _streetController,
    fullName: widget.fullName,
    phoneNumber: widget.phoneNumber,
    provinceController: _provinceController,
    cityController: _cityController,
    barangayController: _barangayController,
    postalCodeController: _postalCodeController,
    isSaving: _isSaving || _isCapturingLocation,
    error: _error,
    onAddressChanged: () {
      if (_error != null) setState(() => _error = null);
    },
    onSave: _save,
  );
}
