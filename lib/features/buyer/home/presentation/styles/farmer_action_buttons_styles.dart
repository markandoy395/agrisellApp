import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_text_styles.dart';

abstract final class FarmerActionButtonsStyles {
  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    shape: const StadiumBorder(),
    padding: EdgeInsets.zero,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static final outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen, width: 1.2),
    shape: const StadiumBorder(),
    padding: EdgeInsets.zero,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static TextStyle labelText(BuildContext context, Color color) =>
      FarmerTextStyles.actionLabel(context).copyWith(color: color);
}
