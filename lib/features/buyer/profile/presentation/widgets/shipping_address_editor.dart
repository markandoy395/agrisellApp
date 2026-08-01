import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:agresell_app/core/utils/map_coordinates.dart';
import 'package:agresell_app/core/utils/written_address.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/buyer/profile/presentation/screens/shipping_address_map_editor_screen.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_editor_content.dart';
import 'package:agresell_app/features/shared/location/data/nominatim_geocoding_service.dart';

class ShippingAddressEditor extends StatefulWidget {
  const ShippingAddressEditor({
    required this.onSave,
    this.initialAddress = '',
    this.fullName = '',
    this.phoneNumber = '',
    this.latitude,
    this.longitude,
    super.key,
  });

  final Future<void> Function(BuyerShippingAddress address) onSave;
  final String initialAddress;
  final String fullName;
  final String phoneNumber;
  final double? latitude;
  final double? longitude;
  @override
  State<ShippingAddressEditor> createState() => _ShippingAddressEditorState();
}

class _ShippingAddressEditorState extends State<ShippingAddressEditor> {
  final _streetController = TextEditingController();
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _barangayController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _geocoder = NominatimGeocodingService();
  Timer? _geocodeTimer;
  LatLng? _point;
  String? _error;
  var _isSaving = false;
  var _isGeocoding = false;
  @override
  void initState() {
    super.initState();
    _streetController.text = widget.initialAddress;
    if (MapCoordinates.isValid(
      latitude: widget.latitude,
      longitude: widget.longitude,
    )) {
      _point = LatLng(widget.latitude!, widget.longitude!);
    }
    _streetController.addListener(_scheduleGeocode);
    _postalCodeController.addListener(_scheduleGeocode);
  }

  @override
  void dispose() {
    _geocodeTimer?.cancel();
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

  void _scheduleGeocode() {
    _geocodeTimer?.cancel();
    _geocodeTimer = Timer(const Duration(milliseconds: 900), _geocodeAddress);
  }

  Future<void> _geocodeAddress() async {
    if (!_isComplete || _isGeocoding) return;
    setState(() {
      _isGeocoding = true;
      _error = null;
    });
    try {
      final point = await _geocoder.geocode(_address);
      if (!mounted) return;
      if (point == null) {
        setState(
          () => _error =
              'We could not locate this address. Adjust it or place the pin manually.',
        );
      } else {
        setState(() => _point = point);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Address lookup is unavailable. Place the pin manually.',
        );
      }
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  Future<void> _openMap() async {
    final selected = await Navigator.of(context).push<BuyerShippingAddress>(
      MaterialPageRoute(
        builder: (_) => ShippingAddressMapEditorScreen(
          initialAddress: _address,
          latitude: _point?.latitude,
          longitude: _point?.longitude,
        ),
      ),
    );
    if (selected == null || !mounted) return;
    if (!MapCoordinates.isValid(
      latitude: selected.latitude,
      longitude: selected.longitude,
    )) {
      setState(
        () => _error = 'The selected map location is invalid. Try again.',
      );
      return;
    }
    setState(() {
      _point = LatLng(selected.latitude!, selected.longitude!);
      _error = null;
    });
  }

  Future<void> _save() async {
    if (!_isComplete || !WrittenAddress.isValid(_address)) {
      setState(
        () => _error = 'Complete your street, barangay, city, and province.',
      );
      return;
    }
    if (_point == null) {
      setState(
        () => _error = 'Select your delivery pin on the map before saving.',
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        BuyerShippingAddress(
          address: _address,
          latitude: _point!.latitude,
          longitude: _point!.longitude,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
    latitude: _point?.latitude,
    longitude: _point?.longitude,
    isGeocoding: _isGeocoding,
    isSaving: _isSaving,
    error: _error,
    onMapTap: _openMap,
    onAddressChanged: () {
      setState(() => _error = null);
      _scheduleGeocode();
    },
    onSave: _save,
  );
}
