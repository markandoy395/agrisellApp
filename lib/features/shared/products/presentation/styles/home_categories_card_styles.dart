import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class HomeCategoriesCardStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.1),
        blurRadius: 14,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static const categoriesText = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static final _textButtonStyleActive = TextButton.styleFrom(
    minimumSize: const Size(0, 34),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    foregroundColor: AgrisellColors.surface,
    textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
  );
  static final _textButtonStyleInactive = TextButton.styleFrom(
    minimumSize: const Size(0, 34),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    foregroundColor: AgrisellColors.surface,
    textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  );
  static ButtonStyle textButtonStyle(bool allSelected) =>
      allSelected ? _textButtonStyleActive : _textButtonStyleInactive;

  static final _animatedContainerDecorationActive = BoxDecoration(
    color: AgrisellColors.forestSoft,
    shape: BoxShape.circle,
    border: Border.all(color: AgrisellColors.authGreen, width: 2),
  );
  static final _animatedContainerDecorationInactive = BoxDecoration(
    color: AgrisellColors.homeBackground,
    shape: BoxShape.circle,
    border: Border.all(color: Colors.transparent, width: 2),
  );
  static BoxDecoration animatedContainerDecoration(bool selected) => selected
      ? _animatedContainerDecorationActive
      : _animatedContainerDecorationInactive;

  static final _textStyleActive = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    height: 1.05,
    fontWeight: FontWeight.w700,
  );
  static final _textStyleInactive = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.05,
    fontWeight: FontWeight.w500,
  );
  static TextStyle textStyle(bool selected) =>
      selected ? _textStyleActive : _textStyleInactive;
}
