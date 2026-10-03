import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_avatar.dart';
import 'package:flutter/material.dart';

class ChatDetailHeaderStyle {
  const ChatDetailHeaderStyle({
    required this.padding,
    required this.decoration,
    required this.avatarStyle,
    required this.titleStyle,
    required this.subtitleStyle,
    this.subtitleSpacing = 0,
  });

  final EdgeInsets padding;
  final Decoration decoration;
  final ChatAvatarStyle avatarStyle;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final double subtitleSpacing;
}
