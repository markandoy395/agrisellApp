import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/presentation/styles/rider_profile_edit_styles.dart';
import 'package:agresell_app/features/rider/profile/presentation/utils/rider_profile_location_coordinator.dart';
import 'package:agresell_app/features/rider/profile/presentation/utils/rider_profile_save_coordinator.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_edit_actions.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_edit_form_fields.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_edit_header.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

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
      padding: RiderProfileEditStyles.sheetPadding(context),
      child: Column(
        children: [
          const RiderProfileEditHeader(),
          RiderProfileEditStyles.spacingLarge,
          Expanded(
            child: SingleChildScrollView(
              child: RiderProfileEditFormFields(
                profile: widget.profile,
                firstNameController: _firstName,
                lastNameController: _lastName,
                contactController: _contact,
                streetController: _street,
                provinceController: _province,
                cityController: _city,
                barangayController: _barangay,
                postalController: _postal,
                licenseController: _license,
                plateController: _plate,
                error: _error,
                onPsgcChanged: () => setState(() {}),
              ),
            ),
          ),
          RiderProfileEditStyles.spacingLarge,
          RiderProfileEditActions(
            isSaving: _isSaving,
            onCancel: () => Navigator.pop(context),
            onSave: _save,
          ),
        ],
      ),
    ),
  );

  Future<void> _save() async {
    final isValid = RiderProfileSaveCoordinator.validate(
      profile: widget.profile,
      firstName: _firstName.text,
      lastName: _lastName.text,
      contact: _contact.text,
      license: _license.text,
      plate: _plate.text,
      street: _street.text,
      province: _province.text,
      city: _city.text,
      barangay: _barangay.text,
    );
    if (!isValid) {
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
      final position =
          await RiderProfileLocationCoordinator.captureCurrentLocation(
            _gpsGateway,
          );
      _latitude = position.latitude;
      _longitude = position.longitude;
      if (!mounted) return;
      Navigator.pop(
        context,
        RiderProfileSaveCoordinator.buildUpdatedProfile(
          original: widget.profile,
          firstName: _firstName.text,
          lastName: _lastName.text,
          contact: _contact.text,
          license: _license.text,
          plate: _plate.text,
          street: _street.text,
          province: _province.text,
          city: _city.text,
          barangay: _barangay.text,
          postal: _postal.text,
          latitude: _latitude,
          longitude: _longitude,
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
}
