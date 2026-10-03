import 'package:flutter/material.dart';
import 'package:agresell_app/features/farmer/registration/presentation/styles/farmer_signup_field_styles.dart';

abstract final class FarmerImagePickerButtonStyles {
  static const containerDecoration = BoxDecoration(
    color: FarmerSignupFieldStyles.pickerIconBoxColor,
    shape: BoxShape.circle,
  );
}
