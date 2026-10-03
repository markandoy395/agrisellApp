import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class LocationGpsStatusStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AgrisellColors.borderLine),
  );
}
