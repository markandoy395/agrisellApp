import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/presentation/utils/rider_profile_location_coordinator.dart';
import 'package:agresell_app/features/rider/profile/presentation/utils/rider_profile_save_coordinator.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_edit_actions.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_edit_form_fields.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_edit_layout.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

part 'rider_profile_edit_save.dart';

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
  void _updateUi(VoidCallback change) => setState(change);
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
  Widget build(BuildContext context) => RiderProfileEditLayout(
    form: RiderProfileEditFormFields(
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
      onPsgcChanged: () {
        if (_error != null) setState(() => _error = null);
      },
    ),
    actions: RiderProfileEditActions(
      isSaving: _isSaving,
      onCancel: () => Navigator.pop(context),
      onSave: _save,
    ),
  );
}
