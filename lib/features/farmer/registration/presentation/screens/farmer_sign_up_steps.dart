part of 'farmer_sign_up_screen.dart';

extension _FarmerSignUpSteps on _FarmerSignUpScreenState {
  Future<void> _next() async {
    if (_step == 2 && !_hasFarmCoordinates) {
      await _captureFarmLocation();
      if (!mounted) return;
    }
    _refresh(() {
      _showAllErrors = true;
      _validateCurrent(showEmpty: true);
    });
    if (_errors.values.any((error) => error != null)) return;
    if (_step == 0) {
      await _verifyEmailBeforePersonalInfo();
      return;
    }
    if (_step < 2) {
      _advanceStep();
      return;
    }
    _submit();
  }

  void _advanceStep() {
    FocusManager.instance.primaryFocus?.unfocus();
    late final bool enteredFarmStep;
    _refresh(() {
      _step += 1;
      enteredFarmStep = _step == 2 && !_requestedFarmLocation;
      _showAllErrors = false;
      _errors.clear();
    });
    if (enteredFarmStep) {
      _requestedFarmLocation = true;
      unawaited(_captureFarmLocation());
    }
  }

  void _previousStep() {
    FocusManager.instance.primaryFocus?.unfocus();
    _refresh(() {
      _step -= 1;
      _showAllErrors = false;
      _errors.clear();
    });
  }
}
