part of 'rider_profile_edit_dialog.dart';

extension _RiderProfileEditSave on _RiderProfileEditSheetState {
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
      _updateUi(
        () => _error = 'Complete the rider details and official address.',
      );
      return;
    }
    _updateUi(() {
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
        _updateUi(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) _updateUi(() => _isSaving = false);
    }
  }
}
