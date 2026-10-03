import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/responsive.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';

abstract final class FarmerSignupSelectFieldStyles {
  static const textStyle = TextStyle(
    fontSize: 13,
    color: AgrisellColors.brandBlack,
  );

  static TextStyle textStyle2(BuildContext context) => TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: lerpDouble(12, 14, authScale(MediaQuery.sizeOf(context).width)),
    fontWeight: FontWeight.w400,
  );

  static InputDecoration inputDecoration(
    String? hint,
    String label,
    TextStyle valueStyle,
  ) => InputDecoration(
    hintText: hint ?? label,
    hintStyle: TextStyle(
      color: AgrisellColors.mutedText,
      fontSize: valueStyle.fontSize,
    ),
    isDense: true,
    filled: true,
    fillColor: AuthInputStyle.fillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
    prefixIcon: AuthInputStyle.iconBadge(AuthInputStyle.iconFor(label)),
    prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 40),
    border: AuthInputStyle.border,
    enabledBorder: AuthInputStyle.border,
    focusedBorder: AuthInputStyle.focusedBorder,
  );
}

abstract final class FarmerSignupDropdownStyle {
  static double height(BuildContext context) {
    final textSize = lerpDouble(
      12,
      14,
      authScale(MediaQuery.sizeOf(context).width),
    );
    final scaled = MediaQuery.textScalerOf(context).scale(textSize);
    return AuthInputStyle.height +
        (scaled - textSize).clamp(0.0, double.infinity) * 2;
  }

  static TextStyle valueStyle(BuildContext context) =>
      FarmerSignupSelectFieldStyles.textStyle2(context);

  static Widget field(
    BuildContext context, {
    required String label,
    required bool floating,
    required Widget child,
  }) => SizedBox(
    height: height(context),
    child: Stack(
      children: [
        Positioned.fill(child: child),
        if (floating)
          Positioned(
            left: 10,
            right: 12,
            top: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              heightFactor: 1,
              child: IgnorePointer(
                child: Container(
                  color: AuthInputStyle.fillColor,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AgrisellTheme.floatingInputLabelStyle,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

  static InputDecoration decoration(
    BuildContext context,
    String label, {
    String? hint,
  }) => FarmerSignupSelectFieldStyles.inputDecoration(
    hint,
    label,
    valueStyle(context),
  );
}
