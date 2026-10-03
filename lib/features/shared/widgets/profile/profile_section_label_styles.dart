import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProfileSectionLabelStyles {
  static const decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(8),
      bottomRight: Radius.circular(8),
    ),
  );
}
