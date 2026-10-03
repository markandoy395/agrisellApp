import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerScreenControlsStyles {
  static final textButtonStyle = TextButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}
