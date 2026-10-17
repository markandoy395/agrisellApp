import 'package:flutter/material.dart';
import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_safe_scaffold.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/app_safety_sheet.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import '../../domain/rider_communication_models.dart';
import '../controllers/rider_messages_controller.dart';
import '../styles/rider_messaging_design_styles.dart';
import 'rider_chat_actions.dart';
import 'rider_chat_messages.dart';
import 'rider_conversation_header.dart';
import 'rider_message_composer.dart';
import 'rider_text_quick_replies.dart';

class RiderConversationPanel extends StatelessWidget {
  const RiderConversationPanel({
    required this.controller,
    required this.quickReplies,
    this.onAction,
    super.key,
  });
  final RiderMessagesController controller;
  final List<RiderQuickReply> quickReplies;
  final RiderCommunicationActionCallback? onAction;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final conversation = controller.selectedConversation;
      if (conversation == null) return const SizedBox.shrink();
      return RiderSafeScaffold(
        backgroundColor: RiderMessagingDesignStyles.background,
        body: Column(
          children: [
            RiderConversationHeader(
              conversation: conversation,
              onSafety: () => _openSafety(context),
            ),
            Expanded(child: RiderMessageBody(controller: controller)),
            RiderTextQuickReplies(
              replies: quickReplies,
              enabled: controller.canCompose && !controller.isSending,
              onSend: controller.send,
            ),
            if (controller.messageError case final message?)
              RiderMessageError(message: message),
            RiderMessageComposer(
              enabled: controller.canCompose,
              isSending: controller.isSending,
              onSend: controller.send,
            ),
          ],
        ),
      );
    },
  );

  Future<void> _openSafety(BuildContext context) async {
    final conversation = controller.selectedConversation;
    if (conversation == null) return;
    if (onAction == null) {
      await showAppSafetySheet(
        context: context,
        role: 'rider',
        deliveryId: int.tryParse(conversation.deliveryId ?? ''),
      );
      return;
    }
    final accepted = await controller.requestAction(
      RiderCommunicationActionType.contactSupport,
    );
    if (!context.mounted) return;
    if (!accepted) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(controller.messageError ?? 'Support is unavailable.'),
        ),
      );
      return;
    }
    await onAction!(
      RiderCommunicationAction(
        type: RiderCommunicationActionType.contactSupport,
        conversationId: conversation.id,
        deliveryId: conversation.deliveryId,
      ),
    );
  }
}

ChatParticipantData riderChatParticipant(RiderConversation conversation) =>
    ChatParticipantData(
      name: conversation.participantLabel,
      initials: conversation.participantLabel
          .trim()
          .split(RegExp(r'\s+'))
          .take(2)
          .map((part) => part.isEmpty ? '' : part[0])
          .join()
          .toUpperCase(),
      imageSemanticLabel: '${conversation.participantLabel} profile',
      imageAsset: conversation.party == RiderConversationParty.support
          ? AgrisellAssets.logoOnly
          : null,
    );
