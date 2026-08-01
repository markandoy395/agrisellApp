import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_avatar.dart';

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

class ChatDetailHeader extends StatelessWidget {
  const ChatDetailHeader({
    required this.participant,
    required this.subtitle,
    required this.onBack,
    required this.style,
    super.key,
  });

  final ChatParticipantData participant;
  final String subtitle;
  final VoidCallback onBack;
  final ChatDetailHeaderStyle style;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: style.padding,
    decoration: style.decoration,
    child: Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back to messages',
          icon: const Icon(Icons.arrow_back_rounded),
          color: AgrisellColors.surface,
        ),
        ChatAvatar(participant: participant, style: style.avatarStyle),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                participant.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.titleStyle,
              ),
              if (style.subtitleSpacing > 0)
                SizedBox(height: style.subtitleSpacing),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.subtitleStyle,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
