import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_messages_controller.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_chat_actions.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_chat_messages.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_message_composer.dart';

class RiderConversationPanel extends StatelessWidget {
  const RiderConversationPanel({
    required this.controller,
    required this.quickReplies,
    this.onAction,
    this.onAttachmentRequested,
    super.key,
  });

  final RiderMessagesController controller;
  final List<RiderQuickReply> quickReplies;
  final RiderCommunicationActionCallback? onAction;
  final RiderCommunicationAttachmentCallback? onAttachmentRequested;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final conversation = controller.selectedConversation;
        if (conversation == null) return const SizedBox.shrink();
        return Material(
          color: AgrisellColors.homeBackground,
          child: Column(
            children: [
              RiderConversationHeader(
                conversation: conversation,
                onClose: () => Navigator.of(context).pop(),
              ),
              Expanded(child: RiderMessageBody(controller: controller)),
              if (quickReplies.isNotEmpty)
                RiderQuickReplyRow(
                  replies: quickReplies,
                  enabled: controller.canCompose && !controller.isSending,
                  onSelected: controller.send,
                ),
              RiderConversationActionRow(
                enabled: controller.canCompose,
                onAction: (type) => _runAction(context, type),
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
  }

  Future<void> _runAction(
    BuildContext context,
    RiderCommunicationActionType type,
  ) async {
    final conversation = controller.selectedConversation;
    if (conversation == null) return;
    final accepted = await controller.requestAction(type);
    if (!context.mounted) return;
    if (!accepted) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(controller.messageError ?? 'Action unavailable.'),
        ),
      );
      return;
    }
    final action = RiderCommunicationAction(
      type: type,
      conversationId: conversation.id,
      deliveryId: conversation.deliveryId,
    );
    final needsAttachment =
        type == RiderCommunicationActionType.attachPhoto ||
        type == RiderCommunicationActionType.shareLocation;
    if (needsAttachment) {
      final attachmentRequested = onAttachmentRequested;
      if (attachmentRequested == null) {
        _showActionMessage(
          context,
          '${riderActionLabel(type)} is unavailable.',
        );
        return;
      }
      final reference = await attachmentRequested(action);
      if (reference == null || !context.mounted) return;
      final sent = type == RiderCommunicationActionType.attachPhoto
          ? await controller.sendPhoto(reference)
          : await controller.sendLocation(reference);
      if (!context.mounted) return;
      _showActionMessage(
        context,
        sent
            ? '${riderActionLabel(type)} sent.'
            : 'Attachment could not be sent.',
      );
      return;
    }

    final runAction = onAction;
    if (runAction == null) {
      _showActionMessage(context, '${riderActionLabel(type)} is unavailable.');
      return;
    }
    await runAction(action);
    if (context.mounted) {
      _showActionMessage(context, '${riderActionLabel(type)} opened.');
    }
  }

  void _showActionMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(message)));
  }
}

class RiderConversationHeader extends StatelessWidget {
  const RiderConversationHeader({
    required this.conversation,
    required this.onClose,
    super.key,
  });

  final RiderConversation conversation;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.participantLabel,
                  style: const TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${conversation.party.label} • In-app delivery chat',
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close conversation',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 20),
          ),
        ],
      ),
    ),
  );
}
