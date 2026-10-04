export 'package:agresell_app/features/shared/chat/presentation/styles/chat_detail_header_styles.dart';
import 'package:agresell_app/features/shared/chat/presentation/styles/chat_detail_header_styles.dart';
import 'package:flutter/material.dart';
import '../styles/chat_reference_styles.dart';

import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_avatar.dart';

class ChatDetailHeader extends StatelessWidget {
  const ChatDetailHeader({
    required this.participant,
    required this.subtitle,
    required this.onBack,
    required this.style,
    this.isEmpty = false,
    this.onCall,
    super.key,
  });

  final bool isEmpty;
  final VoidCallback? onCall;
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
          color: style.titleStyle.color,
        ),
        if (!isEmpty)
          ChatAvatar(participant: participant, style: style.avatarStyle),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: isEmpty
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                isEmpty ? 'Chat' : participant.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.titleStyle,
              ),
              if (!isEmpty && style.subtitleSpacing > 0)
                SizedBox(height: style.subtitleSpacing),
              if (!isEmpty)
                Text(subtitle, softWrap: true, style: style.subtitleStyle),
            ],
          ),
        ),
        if (onCall != null)
          IconButton(
            onPressed: onCall,
            tooltip: 'Protected call',
            icon: const Icon(Icons.call_outlined),
          ),
        PopupMenuButton<String>(
          tooltip: 'Conversation options',
          icon: const Icon(
            Icons.more_vert_rounded,
            color: ChatReferenceStyles.teal,
          ),
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'details',
              child: Text('Conversation details'),
            ),
          ],
          onSelected: (_) => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(participant.name),
              content: Text(subtitle),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
