import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerTextStyles {
  static TextStyle searchHint(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.brandBlack.withValues(alpha: 0.66),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle sellerName(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.surface,
      fontSize: 15,
      fontWeight: FontWeight.w800,
      height: 1.1,
    );
  }

  static TextStyle sellerLocation(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.surface,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1,
    );
  }

  static TextStyle actionLabel(BuildContext context) {
    return _base(context).copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle productLabel(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.authGreen,
      fontSize: 15,
      fontWeight: FontWeight.w800,
    );
  }

  static TextStyle productName(BuildContext context) {
    return _base(context).copyWith(
      color: AgrisellColors.brandBlack,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.1,
    );
  }

  static TextStyle productStatus(BuildContext context, Color color) {
    return productName(context).copyWith(color: color);
  }

  static TextStyle _base(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  }
}
