import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class CategoryFilterStyles {
  static final _containerDecorationActive = BoxDecoration(
    border: const Border(bottom: BorderSide(color: AgrisellColors.dividerLine)),
  );
  static final _containerDecorationInactive = BoxDecoration(border: null);
  static BoxDecoration containerDecoration(bool showDivider) =>
      showDivider ? _containerDecorationActive : _containerDecorationInactive;

  static TextStyle categoryText(Color foreground) =>
      TextStyle(color: foreground, fontWeight: FontWeight.w600);

  static TextStyle textStyle(Color foreground) => TextStyle(color: foreground);
}
