import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProfileTextStyles {
  static TextStyle username(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.surface,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle headerMeta(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.surface,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1,
    );
  }

  static TextStyle sectionLabel(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.surface,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    );
  }

  static TextStyle cardAction(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.mutedText,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle orderLabel(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.brandBlack,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle profileDescription(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.mutedText,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle infoLabel(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.brandBlack,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle infoValue(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.brandBlack,
      fontSize: 13,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle editButton(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.authGreen,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle validationError(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.unavailableRed,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle _base(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  }
}
