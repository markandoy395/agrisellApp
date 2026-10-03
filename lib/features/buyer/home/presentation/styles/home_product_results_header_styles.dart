import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class HomeProductResultsHeaderStyles {
  static final _containerDecorationActive = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AgrisellColors.authGreen),
  );
  static final _containerDecorationInactive = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AgrisellColors.authGreen),
  );
  static BoxDecoration containerDecoration(bool selected) =>
      selected ? _containerDecorationActive : _containerDecorationInactive;

  static final _textStyleActive = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static final _textStyleInactive = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static TextStyle textStyle(bool selected) =>
      selected ? _textStyleActive : _textStyleInactive;
}
