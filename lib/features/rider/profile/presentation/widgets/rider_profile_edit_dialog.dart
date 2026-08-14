import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_address.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/psgc_address_fields.dart';
import 'package:agresell_app/features/shared/widgets/profile/phone_number_sync_control.dart';

Future<RiderProfile?> showRiderProfileEditDialog(
  BuildContext context,
  RiderProfile profile, {
  GpsLocationGateway? gpsGateway,
}) => showModalBottomSheet<RiderProfile>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) =>
      _RiderProfileEditSheet(profile: profile, gpsGateway: gpsGateway),
);

class _RiderProfileEditSheet extends StatefulWidget {
  const _RiderProfileEditSheet({required this.profile, this.gpsGateway});
  final RiderProfile profile;
  final GpsLocationGateway? gpsGateway;

  @override
  State<_RiderProfileEditSheet> createState() => _RiderProfileEditSheetState();
}

class _RiderProfileEditSheetState extends State<_RiderProfileEditSheet> {
  late final _firstName = TextEditingController(text: widget.profile.firstName);
  late final _lastName = TextEditingController(text: widget.profile.lastName);
  late final _contact = TextEditingController(
    text: widget.profile.contactNumber,
  );
  late final _license = TextEditingController(
    text: widget.profile.licenseNumber,
  );
  late final _plate = TextEditingController(
    text: widget.profile.vehiclePlateNumber,
  );
  late final _street = TextEditingController(text: widget.profile.addressLine);
  late final _province = TextEditingController(text: widget.profile.province);
  late final _city = TextEditingController(
    text: widget.profile.cityMunicipality,
  );
  late final _barangay = TextEditingController(text: widget.profile.barangay);
  late final _postal = TextEditingController(text: widget.profile.postalCode);
  late final GpsLocationGateway _gpsGateway;
  late double? _latitude = widget.profile.gpsLatitude;
  late double? _longitude = widget.profile.gpsLongitude;
  String? _error;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _gpsGateway = widget.gpsGateway ?? GeolocatorGpsLocationGateway();
    if (_street.text.trim().isEmpty && widget.profile.addressLine.isEmpty) {
      _street.text = widget.profile.address;
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _contact,
      _license,
      _plate,
      _street,
      _province,
      _city,
      _barangay,
      _postal,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height * .92,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AgrisellColors.borderLine,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Edit rider profile',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Use your official Philippine address. We will capture your exact GPS location when you save.',
              style: TextStyle(fontSize: 12, color: AgrisellColors.mutedText),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field('First name', _firstName, TextInputType.name),
                  _field('Last name', _lastName, TextInputType.name),
                  _field('Contact number', _contact, TextInputType.phone),
                  PhoneNumberSyncControl(controller: _contact),
                  const SizedBox(height: 8),
                  const Text(
                    'Official address',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  _field(
                    'House, building, street, or sitio',
                    _street,
                    TextInputType.streetAddress,
                  ),
                  PsgcAddressFields(
                    provinceController: _province,
                    cityController: _city,
                    barangayController: _barangay,
                    onChanged: () => setState(() {}),
                  ),
                  _field(
                    'Postal code (optional)',
                    _postal,
                    TextInputType.number,
                  ),
                  if (widget.profile.vehicleType.requiresLicense)
                    _field('License number', _license, TextInputType.text),
                  if (widget.profile.vehicleType.requiresPlate)
                    _field('Vehicle plate number', _plate, TextInputType.text),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AgrisellColors.statusRedText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save changes'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
    ),
  );

  Future<void> _save() async {
    final completeAddress = RiderAddress.isComplete(
      addressLine: _street.text,
      barangay: _barangay.text,
      cityMunicipality: _city.text,
      province: _province.text,
    );
    final required = [
      _firstName,
      _lastName,
      _contact,
      if (widget.profile.vehicleType.requiresLicense) _license,
      if (widget.profile.vehicleType.requiresPlate) _plate,
    ];
    if (required.any((item) => item.text.trim().isEmpty) || !completeAddress) {
      setState(
        () => _error = 'Complete the rider details and official address.',
      );
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await _captureCurrentLocation();
      if (!mounted) return;
      Navigator.pop(
        context,
        widget.profile.copyWith(
          fullName: '${_firstName.text.trim()} ${_lastName.text.trim()}',
          contactNumber: _contact.text.trim(),
          licenseNumber: widget.profile.vehicleType.requiresLicense
              ? _license.text.trim().toUpperCase()
              : widget.profile.licenseNumber,
          vehiclePlateNumber: widget.profile.vehicleType.requiresPlate
              ? _plate.text.trim().toUpperCase()
              : widget.profile.vehiclePlateNumber,
          addressLine: _street.text.trim(),
          barangay: _barangay.text.trim(),
          cityMunicipality: _city.text.trim(),
          province: _province.text.trim(),
          postalCode: _postal.text.trim(),
          address: RiderAddress.format(
            addressLine: _street.text,
            barangay: _barangay.text,
            cityMunicipality: _city.text,
            province: _province.text,
            postalCode: _postal.text,
          ),
          gpsLatitude: _latitude,
          gpsLongitude: _longitude,
        ),
      );
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
        'Allow location access so we can capture your exact location.',
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
  }
}
