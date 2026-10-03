import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';

abstract final class AuthTextFieldDecorationStyles {
  static InputDecoration inputDecoration(
    bool isFloating,
    String hintText,
    double textSize,
    EdgeInsets contentPadding,
    OutlineInputBorder border,
    OutlineInputBorder errorBorder,
    IconData? leadingIcon,
    BoxConstraints prefixIconConstraints,
    bool isPassword,
    IconData? trailingIcon,
    BoxConstraints suffixIconConstraints,
    bool isHidden,
    void Function() onTogglePassword,
  ) => InputDecoration(
    hintText: isFloating ? null : hintText,
    hintStyle: TextStyle(color: AgrisellColors.mutedText, fontSize: textSize),
    isDense: true,
    filled: true,
    fillColor: AuthInputStyle.fillColor,
    contentPadding: contentPadding,
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: AgrisellColors.authGreen, width: 1.5),
    ),
    errorBorder: errorBorder,
    focusedErrorBorder: errorBorder,
    disabledBorder: border,
    prefixIcon: AuthInputStyle.iconBadge(
      leadingIcon ?? AuthInputStyle.iconFor(hintText),
    ),
    prefixIconConstraints: prefixIconConstraints,
    suffixIconConstraints: isPassword || trailingIcon != null
        ? suffixIconConstraints
        : null,
    suffixIcon: isPassword
        ? IconButton(
            tooltip: isHidden ? 'Show password' : 'Hide password',
            onPressed: onTogglePassword,
            constraints: suffixIconConstraints,
            padding: EdgeInsets.zero,
            iconSize: 20,
            color: AgrisellColors.authGreen,
            icon: Icon(
              isHidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          )
        : trailingIcon != null
        ? Icon(trailingIcon, color: AgrisellColors.mutedText, size: 22)
        : null,
  );
}

abstract final class AuthTextFieldDecoration {
  static const suffixIconConstraints = BoxConstraints(
    minWidth: 48,
    minHeight: 40,
  );
  static const prefixIconConstraints = BoxConstraints(
    minWidth: 52,
    minHeight: 40,
  );
  static const contentPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 18,
  );

  static InputDecoration build({
    required String hintText,
    required double textSize,
    required bool isFloating,
    required bool isPassword,
    required bool isHidden,
    required VoidCallback onTogglePassword,
    IconData? leadingIcon,
    IconData? trailingIcon,
  }) {
    const border = AuthInputStyle.border;
    final errorBorder = border.copyWith(
      borderSide: const BorderSide(color: AgrisellColors.statusRedText),
    );

    return AuthTextFieldDecorationStyles.inputDecoration(
      isFloating,
      hintText,
      textSize,
      contentPadding,
      border,
      errorBorder,
      leadingIcon,
      prefixIconConstraints,
      isPassword,
      trailingIcon,
      suffixIconConstraints,
      isHidden,
      onTogglePassword,
    );
  }
}
