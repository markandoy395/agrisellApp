export 'package:agresell_app/features/shared/chat/presentation/styles/chat_content_state_styles.dart';
import 'package:agresell_app/features/shared/chat/presentation/styles/chat_content_state_styles.dart';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class ChatContentStateData {
  const ChatContentStateData({this.icon, this.title, this.message});

  final IconData? icon;
  final String? title;
  final String? message;
}

class ChatContentState extends StatelessWidget {
  const ChatContentState({
    required this.data,
    this.style = const ChatContentStateStyle(),
    this.action,
    super.key,
  });

  final ChatContentStateData data;
  final ChatContentStateStyle style;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: style.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.icon case final icon?) ...[
            Icon(icon, color: style.iconColor, size: style.iconSize),
            if (data.title != null || data.message != null || action != null)
              SizedBox(height: style.iconSpacing),
          ],
          if (data.title case final title?) ...[
            Text(title, textAlign: TextAlign.center, style: style.titleStyle),
            if (data.message != null)
              SizedBox(height: style.titleMessageSpacing),
          ],
          if (data.message case final message?)
            Text(
              message,
              textAlign: TextAlign.center,
              style: style.messageStyle,
            ),
          if (action != null) ...[
            if (data.icon != null || data.title != null || data.message != null)
              SizedBox(height: style.actionSpacing),
            action!,
          ],
        ],
      ),
    ),
  );
}

class ChatLoadingState extends StatelessWidget {
  const ChatLoadingState({
    required this.semanticLabel,
    this.color = AgrisellColors.authGreen,
    super.key,
  });

  final String semanticLabel;
  final Color? color;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: semanticLabel,
      child: CircularProgressIndicator(color: color),
    ),
  );
}
