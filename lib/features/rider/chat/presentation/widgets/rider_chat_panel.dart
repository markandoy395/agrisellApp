import 'package:agresell_app/features/shared/chat/presentation/styles/chat_reference_styles.dart';
import 'package:agresell_app/features/shared/chat/presentation/models/chat_participant_data.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_detail_header.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/app_safety_sheet.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

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
          color: ChatReferenceStyles.background,
          child: Column(
            children: [
              ChatDetailHeader(
                participant: riderChatParticipant(conversation),
                subtitle: conversation.party.label + ' / Delivery chat',
                isEmpty: controller.messages.isEmpty,
                style: ChatReferenceStyles.header(
                  MediaQuery.paddingOf(context).top,
                ),
                onBack: () => Navigator.of(context).pop(),
                onCall: onAction == null || !controller.canCompose
                    ? null
                    : () => _runAction(
                        context,
                        RiderCommunicationActionType.call,
                      ),
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
                onOutside: () => controller.send("I'm outside."),
              ),
              if (controller.messageError case final message?)
                RiderMessageError(message: message),
              RiderMessageComposer(
                enabled: controller.canCompose,
                isSending: controller.isSending,
                onSend: controller.send,
                onAttach: onAttachmentRequested == null
                    ? null
                    : () => _runAction(
                        context,
                        RiderCommunicationActionType.attachPhoto,
                      ),
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
    if (type == RiderCommunicationActionType.contactSupport &&
        onAction == null) {
      await showAppSafetySheet(
        context: context,
        role: 'rider',
        deliveryId: int.tryParse(conversation.deliveryId ?? ''),
      );
      return;
    }
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
      imageSemanticLabel: conversation.participantLabel + ' profile',
    );
