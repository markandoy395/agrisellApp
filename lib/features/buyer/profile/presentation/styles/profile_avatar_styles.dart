import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProfileAvatarStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.forestDark,
    shape: BoxShape.circle,
    border: Border.all(color: AgrisellColors.surface, width: 2),
    boxShadow: const [
      BoxShadow(color: Color(0x330B0B0B), blurRadius: 5, offset: Offset(0, 2)),
    ],
  );
}
