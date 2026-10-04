import 'package:flutter/material.dart';
import '../models/chat_participant_data.dart';
import '../styles/chat_reference_styles.dart';
import 'chat_avatar.dart';

class ChatProfileIntro extends StatelessWidget {
  const ChatProfileIntro({
    required this.participant,
    required this.subtitle,
    super.key,
  });
  final ChatParticipantData participant;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    key: const ValueKey('chat-profile-intro'),
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
    child: Column(
      children: [
        ChatAvatar(
          participant: participant,
          style: ChatReferenceStyles.avatar(84),
        ),
        const SizedBox(height: 16),
        Text(
          participant.name,
          textAlign: TextAlign.center,
          style: ChatReferenceStyles.title,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: ChatReferenceStyles.subtitle,
        ),
      ],
    ),
  );
}

class ChatSuggestedReplies extends StatelessWidget {
  const ChatSuggestedReplies({
    required this.replies,
    required this.onSelected,
    super.key,
  });
  final List<String> replies;
  final ValueChanged<String>? onSelected;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 58,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: replies.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) => OutlinedButton(
        style: ChatReferenceStyles.actionButton,
        onPressed: onSelected == null
            ? null
            : () => onSelected!(replies[index]),
        child: Text(replies[index]),
      ),
    ),
  );
}
