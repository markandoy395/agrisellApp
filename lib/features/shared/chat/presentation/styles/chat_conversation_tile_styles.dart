import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ChatConversationTileStyles {
  static const containerDecoration = BoxDecoration(
    border: Border(bottom: BorderSide(color: AgrisellColors.borderLine)),
  );

  static TextStyle textStyle(double? avatarTextHeight) => TextStyle(
    fontSize: 13,
    height: avatarTextHeight,
    fontWeight: FontWeight.w800,
  );

  static final _textStyle2Active = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );
  static final _textStyle2Inactive = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
  static TextStyle textStyle2(bool hasUnread) =>
      hasUnread ? _textStyle2Active : _textStyle2Inactive;

  static final _textStyle3Active = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  static final _textStyle3Inactive = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );
  static TextStyle textStyle3(bool hasUnread) =>
      hasUnread ? _textStyle3Active : _textStyle3Inactive;

  static final _textStyle4Active = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static final _textStyle4Inactive = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static TextStyle textStyle4(bool hasUnread) =>
      hasUnread ? _textStyle4Active : _textStyle4Inactive;
}
