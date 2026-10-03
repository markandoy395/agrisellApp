import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderConversationListStyles {
  static final _textStyleActive = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );
  static final _textStyleInactive = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
  static TextStyle textStyle(bool hasUnread) =>
      hasUnread ? _textStyleActive : _textStyleInactive;

  static const containerDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  static const textStyle2 = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}
