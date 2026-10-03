import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/responsive.dart';

abstract final class AuthBottomLinkStyles {
  static TextStyle labelText(double scale) => TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: lerpDouble(12, 14, scale),
    fontWeight: FontWeight.w400,
  );

  static ButtonStyle textButtonStyle(double scale) => TextButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    padding: EdgeInsets.zero,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textStyle: TextStyle(
      fontSize: lerpDouble(13, 15, scale),
      fontWeight: FontWeight.w500,
    ),
  );
}
