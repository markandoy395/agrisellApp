import 'dart:async';
import 'farmer_farm_form_style.dart';
import 'farmer_profile_style.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/profile/data/farmer_farm_service.dart';
import 'package:agresell_app/features/farmer/registration/domain/farm_model.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/psgc_address_fields.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

class FarmerFarmEditCard extends StatefulWidget {
  const FarmerFarmEditCard({
    required this.onCancel,
    this.service,
    this.gpsGateway,
    super.key,
  });
  final VoidCallback onCancel;
  final FarmerFarmService? service;
  final GpsLocationGateway? gpsGateway;
  @override
  State<FarmerFarmEditCard> createState() => _FarmerFarmEditCardState();
}

class _FarmerFarmEditCardState extends State<FarmerFarmEditCard>
    with WidgetsBindingObserver {
  late final FarmerFarmService _service;
  late final GpsLocationGateway _gpsGateway;
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _barangayController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _sizeController = TextEditingController();
  final _farmingTypeController = TextEditingController();
  final _irrigationController = TextEditingController();
  final _cropsController = TextEditingController();
  FarmModel? _farm;
  var _loading = true;
  var _saving = false;
  var _capturing = false;
  String? _locationError;
  double? _latitude;
  double? _longitude;
  @override
  void initState() {
    super.initState();
    _service = widget.service ?? const FarmerFarmService();
    _gpsGateway = widget.gpsGateway ?? GeolocatorGpsLocationGateway();
    WidgetsBinding.instance.addObserver(this);
    _load();
    unawaited(_startGpsCapture());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _locationController.dispose();
    _barangayController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _sizeController.dispose();
    _farmingTypeController.dispose();
    _irrigationController.dispose();
    _cropsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final farm = await _service.load();
      if (!mounted) return;
      _farm = farm;
      _nameController.text = farm?.name ?? '';
      _locationController.text = farm?.location ?? '';
      _barangayController.text = farm?.barangay ?? '';
      _cityController.text = farm?.cityMunicipality ?? '';
      _provinceController.text = farm?.province ?? '';
      _sizeController.text = farm?.size?.toString() ?? '';
      _farmingTypeController.text = farm?.farmingType ?? '';
      _irrigationController.text = farm?.irrigationType ?? '';
      _cropsController.text = farm?.mainCrops.join(', ') ?? '';
    } on FarmerFarmException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_saving || _capturing) return;
    final requiredValues = {
      'Farm Name': _nameController.text,
      'Farm Address': _locationController.text,
      'Province': _provinceController.text,
      'City or municipality': _cityController.text,
      'Barangay': _barangayController.text,
      'Farming Type': _farmingTypeController.text,
      'Main Crops': _cropsController.text,
    };
    for (final entry in requiredValues.entries) {
      if (entry.value.trim().isEmpty) {
        _message('Enter ' + entry.key + '.');
        return;
      }
    }
    final size = double.tryParse(_sizeController.text.trim());
    if (size == null || !size.isFinite || size <= 0) {
      _message('Enter a valid farm size in hectares.');
      return;
    }
    setState(() => _saving = true);
    try {
      if (_latitude == null || _longitude == null) {
        await _startGpsCapture();
        if (_latitude == null || _longitude == null) return;
      }
      if (!mounted) return;
      final farm = await _service.save(
        FarmEditDraft(
          name: _nameController.text,
          location: _blank(_locationController.text),
          barangay: _blank(_barangayController.text),
          cityMunicipality: _blank(_cityController.text),
          province: _blank(_provinceController.text),
          latitude: _latitude,
          longitude: _longitude,
          size: double.tryParse(_sizeController.text.trim()),
          farmingType: _blank(_farmingTypeController.text),
          irrigationType: _blank(_irrigationController.text),
          mainCrops: _cropsController.text
              .split(',')
              .map((crop) => crop.trim())
              .where((crop) => crop.isNotEmpty)
              .toList(growable: false),
        ),
        farmId: _farm?.id,
      );
      if (!mounted) return;
      setState(() => _farm = farm);
      _message('Farm details saved.');
      widget.onCancel();
    } on FarmerFarmException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _captureCurrentLocation({bool openSettings = true}) async {
    try {
      if (!await _gpsGateway.isServiceEnabled()) {
        if (openSettings) await _gpsGateway.openLocationSettings();
        throw const FarmerFarmException(
          'Turn on location services, then return to capture your farm location.',
        );
      }
      var permission = await _gpsGateway.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _gpsGateway.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const FarmerFarmException(
          'Allow location access so we can capture your farm location.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        if (openSettings) await _gpsGateway.openAppSettings();
        throw const FarmerFarmException(
          'Allow location permission in app settings, then return to capture your farm location.',
        );
      }
      if (await _gpsGateway.getAccuracyStatus() ==
          LocationAccuracyStatus.reduced) {
        if (openSettings) await _gpsGateway.openAppSettings();
        throw const FarmerFarmException(
          'Enable precise location, then return to capture your farm location.',
        );
      }
      final position = await _gpsGateway.currentPosition(
        settings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!position.latitude.isFinite ||
          !position.longitude.isFinite ||
          position.latitude < -90 ||
          position.latitude > 90 ||
          position.longitude < -180 ||
          position.longitude > 180) {
        throw const FarmerFarmException(
          'GPS returned an invalid farm location. Try again.',
        );
      }
      _latitude = position.latitude;
      _longitude = position.longitude;
    } on FarmerFarmException {
      rethrow;
    } on TimeoutException {
      throw const FarmerFarmException(
        'Location took too long. Check your GPS signal and try again.',
      );
    } catch (_) {
      throw const FarmerFarmException(
        'Current farm location could not be captured. Try again.',
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !_capturing &&
        (_latitude == null || _longitude == null)) {
      unawaited(_startGpsCapture(openSettings: false));
    }
  }

  Future<void> _startGpsCapture({bool openSettings = true}) async {
    if (_capturing) return;
    setState(() {
      _capturing = true;
      _locationError = null;
    });
    try {
      await _captureCurrentLocation(openSettings: openSettings);
    } on FarmerFarmException catch (error) {
      if (mounted) setState(() => _locationError = error.message);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  String? _blank(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  void _message(String value) {
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) => FarmerProfileCard(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Farm',
                  style: TextStyle(
                    color: Color(0xFF14763D),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Update the farm used for your product listings.',
                  style: TextStyle(color: Color(0xFF677999), fontSize: 14),
                ),
                const SizedBox(height: 20),
                if (_capturing) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text(
                    'Capturing your current farm location...',
                    style: TextStyle(
                      color: FarmerProfileStyle.muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_locationError != null) ...[
                  Text(
                    _locationError!,
                    style: const TextStyle(
                      color: Color(0xFFAB342D),
                      fontSize: 13,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _capturing ? null : () => _startGpsCapture(),
                    icon: const Icon(Icons.my_location_rounded),
                    label: const Text('Retry GPS capture'),
                  ),
                  const SizedBox(height: 8),
                ],
                FarmerFarmField(
                  label: 'Farm Name',
                  icon: Icons.spa_rounded,
                  controller: _nameController,
                ),
                FarmerFarmField(
                  label: 'Farm Address',
                  icon: Icons.home_rounded,
                  controller: _locationController,
                ),
                PsgcAddressFields(
                  provinceController: _provinceController,
                  cityController: _cityController,
                  barangayController: _barangayController,
                  onChanged: () => setState(() {}),
                  decorationTheme: FarmerFarmFormStyle.decoration,
                  labelBuilder: (label) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FarmerFarmFormStyle.label(
                      '$label (select or type)',
                      switch (label) {
                        'Province' => Icons.map_outlined,
                        'Barangay' => Icons.location_on_rounded,
                        _ => Icons.location_city_rounded,
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FarmerFarmField(
                  label: 'Size (hectares)',
                  icon: Icons.view_week_rounded,
                  controller: _sizeController,
                  inline: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                FarmerFarmField(
                  label: 'Farming Type',
                  icon: Icons.eco_rounded,
                  controller: _farmingTypeController,
                  inline: true,
                ),
                FarmerFarmField(
                  label: 'Irrigation Type',
                  icon: Icons.water_drop_outlined,
                  controller: _irrigationController,
                  inline: true,
                  required: false,
                  hint: 'Select irrigation type',
                ),
                FarmerFarmField(
                  label: 'Main Crops',
                  icon: Icons.grass_rounded,
                  controller: _cropsController,
                  inline: true,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: OutlinedButton(
                        onPressed: _saving ? null : widget.onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: FarmerProfileStyle.green,
                          minimumSize: const Size(125, 48),
                          side: const BorderSide(
                            color: FarmerProfileStyle.green,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: FilledButton(
                        onPressed: _saving || _capturing ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF14763D),
                          minimumSize: const Size(140, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _saving ? 'Saving...' : 'Save Farm',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    ),
  );
}
