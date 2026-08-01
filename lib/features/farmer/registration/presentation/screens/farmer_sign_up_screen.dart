import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/authRegistrationService.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/auth_dashboard_router.dart';
import 'package:agresell_app/features/auth/presentation/screens/loginScreen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authScaffold.dart';
import 'package:agresell_app/features/farmer/registration/domain/farmer_signup_validator.dart';
import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_account_step.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_farm_step.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_personal_step.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/presentation/location_selector.dart';

part 'farmer_sign_up_actions.dart';
part 'farmer_sign_up_validation.dart';

class FarmerSignUpScreen extends StatefulWidget {
  const FarmerSignUpScreen({super.key});
  @override
  State<FarmerSignUpScreen> createState() => _FarmerSignUpScreenState();
}

class _FarmerSignUpScreenState extends State<FarmerSignUpScreen> {
  final _controllers = FarmerSignupControllers();
  final _errors = <String, String?>{};
  var _step = 0;
  var _showAllErrors = false;
  var _isSubmitting = false;
  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_controllers.isDirty || _isSubmitting,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && !_isSubmitting) _confirmDiscard();
    },
    child: AuthScaffold(
      key: ValueKey(_step),
      title: 'Farmer Sign Up',
      scrollable: false,
      child: Column(
        children: [
          _progress(),
          const SizedBox(height: 14),
          Expanded(
            child: SingleChildScrollView(
              key: const PageStorageKey('farmer-signup-step-scroll'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: _currentStep(),
            ),
          ),
          const SizedBox(height: 14),
          _controls(),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isSubmitting ? null : _goToLogin,
            child: const Text('Already have an account? Log in'),
          ),
        ],
      ),
    ),
  );
  Widget _progress() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Step ${_step + 1} of 3',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      LinearProgressIndicator(value: (_step + 1) / 3, minHeight: 5),
    ],
  );
  Widget _currentStep() => switch (_step) {
    0 => FarmerSignupAccountStep(
      controllers: _controllers,
      errors: _errors,
      onChanged: _onChanged,
    ),
    1 => FarmerSignupPersonalStep(
      controllers: _controllers,
      errors: _errors,
      onChanged: _onChanged,
      onPickDate: _pickDate,
      onPickImage: () => _pickImage(profile: true),
    ),
    _ => FarmerSignupFarmStep(
      controllers: _controllers,
      errors: _errors,
      onChanged: _onChanged,
      onPickLocation: _pickLocation,
      onPickImage: () => _pickImage(profile: false),
    ),
  };
  Widget _controls() => Row(
    children: [
      if (_step > 0)
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : _previousStep,
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
            child: const Text('Back'),
          ),
        ),
      if (_step > 0) const SizedBox(width: 10),
      Expanded(
        child: FilledButton(
          onPressed: _isSubmitting ? null : _next,
          style: FilledButton.styleFrom(minimumSize: const Size(0, 38)),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_step == 2 ? 'Submit registration' : 'Continue'),
        ),
      ),
    ],
  );
  void _onChanged() => setState(() => _validateCurrent(showEmpty: false));
  void _refresh(VoidCallback update) => setState(update);

  void _next() {
    setState(() {
      _showAllErrors = true;
      _validateCurrent(showEmpty: true);
    });
    if (_errors.values.any((error) => error != null)) return;
    if (_step < 2) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        _step += 1;
        _showAllErrors = false;
        _errors.clear();
      });
      return;
    }
    _submit();
  }

  void _previousStep() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _step -= 1;
      _showAllErrors = false;
      _errors.clear();
    });
  }
}
