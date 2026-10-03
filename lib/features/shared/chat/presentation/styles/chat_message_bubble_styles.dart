import 'package:agresell_app/core/theme/shared_presentation_styles.dart';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ChatMessageBubbleStyles {
  static BoxDecoration containerDecoration(
    Color background,
    BorderRadius radius,
    bool failed,
  ) => BoxDecoration(
    color: background,
    borderRadius: radius,
    border: failed ? Border.all(color: AgrisellColors.statusRedText) : null,
  );

  static TextStyle textStyle(Color textColor) => TextStyle(
    color: textColor,
    fontSize: 12,
    height: 1.32,
    fontWeight: FontWeight.w500,
  );

  static TextStyle statusText(ChatMessageBubbleStyle style, bool failed) =>
      style.statusTextStyle.copyWith(
        color: failed ? AgrisellColors.statusRedText : AgrisellColors.mutedText,
      );
}

class ChatMessageBubbleStyle {
  const ChatMessageBubbleStyle({
    this.statusTextStyle = SharedPresentationStyles.caption,
    this.statusMaxLines,
    this.statusOverflow,
  });

  final TextStyle statusTextStyle;
  final int? statusMaxLines;
  final TextOverflow? statusOverflow;
}
