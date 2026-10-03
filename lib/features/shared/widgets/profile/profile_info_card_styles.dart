import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProfileInfoCardStyles {
  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen, width: 1.4),
    shape: const StadiumBorder(),
    padding: EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}
