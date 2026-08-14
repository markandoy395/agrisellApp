part of 'farmer_sign_up_screen.dart';

extension _FarmerSignUpValidation on _FarmerSignUpScreenState {
  bool get _hasFarmCoordinates =>
      _controllers.latitude.text.trim().isNotEmpty &&
      _controllers.longitude.text.trim().isNotEmpty &&
      FarmerSignupValidator.farmCoordinates(
            _controllers.latitude.text,
            _controllers.longitude.text,
          ) ==
          null;

  void _validateCurrent({required bool showEmpty}) {
    _errors.clear();
    final show = showEmpty || _showAllErrors;
    if (_step == 0) {
      _put(
        'email',
        FarmerSignupValidator.email(_controllers.email.text),
        _controllers.email.text,
        show,
      );
      _put(
        'password',
        FarmerSignupValidator.password(_controllers.password.text),
        _controllers.password.text,
        show,
      );
      _put(
        'confirmPassword',
        FarmerSignupValidator.passwordConfirmation(
          _controllers.password.text,
          _controllers.confirmPassword.text,
        ),
        _controllers.confirmPassword.text,
        show,
      );
    } else if (_step == 1) {
      _requiredProfileFields(show);
    } else {
      _requiredFarmFields(show);
    }
  }

  void _requiredProfileFields(bool show) {
    _put(
      'firstName',
      FarmerSignupValidator.required(
        _controllers.firstName.text,
        'your first name',
      ),
      _controllers.firstName.text,
      show,
    );
    _put(
      'lastName',
      FarmerSignupValidator.required(
        _controllers.lastName.text,
        'your last name',
      ),
      _controllers.lastName.text,
      show,
    );
    _put(
      'phone',
      FarmerSignupValidator.phone(_controllers.phone.text),
      _controllers.phone.text,
      show,
    );
    _put(
      'dateOfBirth',
      FarmerSignupValidator.dateOfBirth(_controllers.dateOfBirth.text),
      _controllers.dateOfBirth.text,
      show,
    );
  }

  void _requiredFarmFields(bool show) {
    _put(
      'farmLocation',
      FarmerSignupValidator.farmCoordinates(
        _controllers.latitude.text,
        _controllers.longitude.text,
      ),
      '${_controllers.latitude.text}${_controllers.longitude.text}',
      show,
    );
    _put(
      'farmName',
      FarmerSignupValidator.required(
        _controllers.farmName.text,
        'the farm name',
      ),
      _controllers.farmName.text,
      show,
    );
    _put(
      'farmAddress',
      FarmerSignupValidator.required(
        _controllers.farmAddress.text,
        'the farm address',
      ),
      _controllers.farmAddress.text,
      show,
    );
    final addressDetails = [
      _controllers.farmBarangay.text,
      _controllers.farmCity.text,
      _controllers.farmProvince.text,
    ];
    _put(
      'farmAddressDetails',
      addressDetails.every((value) => value.trim().isNotEmpty)
          ? null
          : 'Complete the farm barangay, city, and province.',
      addressDetails.join(),
      show,
    );
    _put(
      'mainCrops',
      FarmerSignupValidator.required(
        _controllers.mainCrops.text,
        'at least one main crop',
      ),
      _controllers.mainCrops.text,
      show,
    );
    _put(
      'yearsOfExperience',
      FarmerSignupValidator.wholeNumber(
        _controllers.yearsOfExperience.text,
        'your years of farming experience',
      ),
      _controllers.yearsOfExperience.text,
      show,
    );
    _put(
      'farmSize',
      FarmerSignupValidator.number(_controllers.farmSize.text, 'farm size'),
      _controllers.farmSize.text,
      show,
    );
    _put(
      'farmSizeUnit',
      FarmerSignupValidator.required(
        _controllers.farmSizeUnit.text,
        'the farm size unit',
      ),
      _controllers.farmSizeUnit.text,
      show,
    );
    _put(
      'farmingType',
      FarmerSignupValidator.required(
        _controllers.farmingType.text,
        'the farming type',
      ),
      _controllers.farmingType.text,
      show,
    );
  }

  void _put(String key, String? error, String value, bool showEmpty) {
    _errors[key] = showEmpty || value.trim().isNotEmpty ? error : null;
  }
}
