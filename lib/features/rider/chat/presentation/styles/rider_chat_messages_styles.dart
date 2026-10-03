import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderChatMessagesStyles {
  static final _decoratedBoxDecorationActive = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.circular(12),
    border: null,
  );
  static final _decoratedBoxDecorationInactive = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static BoxDecoration decoratedBoxDecoration(bool sentByRider) => sentByRider
      ? _decoratedBoxDecorationActive
      : _decoratedBoxDecorationInactive;

  static final _textStyleActive = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w500,
  );
  static final _textStyleInactive = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w500,
  );
  static TextStyle textStyle(bool sentByRider) =>
      sentByRider ? _textStyleActive : _textStyleInactive;

  static const textStyle2 = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
