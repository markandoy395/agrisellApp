import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/rider_communication_models.dart';
import '../styles/rider_messaging_design_styles.dart';

class RiderConversationAvatar extends StatelessWidget {
  const RiderConversationAvatar({
    required this.conversation,
    this.radius = 23,
    super.key,
  });
  final RiderConversation conversation;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = conversation.participantLabel
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((part) => part.isEmpty ? '' : part[0])
        .join()
        .toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: RiderMessagingDesignStyles.avatarColor(
        conversation.party,
      ),
      foregroundColor: AgrisellColors.authGreen,
      child: conversation.party == RiderConversationParty.support
          ? const Icon(Icons.verified_user_outlined)
          : Text(initials, style: RiderMessagingDesignStyles.title),
    );
  }
}
