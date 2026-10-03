import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:flutter/material.dart';

class ChatContentStateStyle {
  const ChatContentStateStyle({
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 100),
    this.iconColor = AgrisellColors.authGreen,
    this.iconSize = 34,
    this.titleStyle = SharedPresentationStyles.headingSubtitleExtraBold,
    this.messageStyle = SharedPresentationStyles.mutedCaption,
    this.iconSpacing = 10,
    this.titleMessageSpacing = 5,
    this.actionSpacing = 12,
  });

  final EdgeInsets padding;
  final Color iconColor;
  final double iconSize;
  final TextStyle titleStyle;
  final TextStyle messageStyle;
  final double iconSpacing;
  final double titleMessageSpacing;
  final double actionSpacing;
}
