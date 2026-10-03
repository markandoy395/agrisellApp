import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

abstract final class ProfileDateOfBirthRowStyles {
  static TextStyle buttonStyle(BuildContext context) =>
      ProfileTextStyles.infoValue(context).copyWith(height: 1);
}
