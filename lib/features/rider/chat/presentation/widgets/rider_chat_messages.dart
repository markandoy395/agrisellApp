import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_loading_skeleton.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_profile_intro.dart';
import '../../domain/rider_communication_models.dart';
import '../controllers/rider_messages_controller.dart';
import '../styles/rider_chat_messages_styles.dart';
import '../styles/rider_messaging_design_styles.dart';
import 'rider_chat_panel.dart';

class RiderMessageBody extends StatelessWidget {
  const RiderMessageBody({required this.controller, super.key});
  final RiderMessagesController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingMessages)
      return const ChatLoadingSkeleton(conversations: false);
    if (controller.messages.isEmpty) {
      final conversation = controller.selectedConversation!;
      return ListView(
        children: [
          ChatProfileIntro(
            participant: riderChatParticipant(conversation),
            subtitle: '${conversation.party.label} / Delivery chat',
          ),
        ],
      );
    }
    final messages = controller.messages;
    return ListView.builder(
      key: ValueKey(controller.selectedConversation?.id),
      reverse: true,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final position = messages.length - 1 - index;
        final message = messages[position];
        final date = DateUtils.dateOnly(message.sentAt.toLocal());
        final showDate =
            position == 0 ||
            date != DateUtils.dateOnly(messages[position - 1].sentAt.toLocal());
        return Column(
          key: ValueKey(message.id),
          children: [
            if (showDate)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 6,
                  ),
                  decoration: RiderChatMessagesStyles.day,
                  child: Text(
                    date == DateUtils.dateOnly(DateTime.now())
                        ? 'TODAY'
                        : MaterialLocalizations.of(
                            context,
                          ).formatShortDate(date),
                    style: RiderMessagingDesignStyles.caption,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: RiderMessageBubble(
                message: message,
                onRetry: message.isFailed
                    ? () => controller.retryFailedMessage(message.id)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class RiderMessageBubble extends StatelessWidget {
  const RiderMessageBubble({required this.message, this.onRetry, super.key});
  final RiderChatMessage message;
  final Future<bool> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final sentByRider = message.sender == RiderMessageSender.rider;
    final system =
        message.sender == RiderMessageSender.system ||
        message.kind == RiderMessageKind.deliveryUpdate ||
        message.kind == RiderMessageKind.system;
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(message.sentAt.toLocal()));
    if (system)
      return Column(
        children: [
          Text('Delivery update', style: RiderMessagingDesignStyles.caption),
          const SizedBox(height: 4),
          Text(
            '${riderMessageText(message)} · $time',
            textAlign: TextAlign.center,
            style: RiderMessagingDesignStyles.muted,
          ),
        ],
      );
    return Align(
      alignment: sentByRider ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .8,
        ),
        child: Container(
          decoration: RiderChatMessagesStyles.decoratedBoxDecoration(
            sentByRider,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                riderMessageText(message),
                style: RiderMessagingDesignStyles.body,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (sentByRider) ...[
                    Icon(
                      switch (message.status) {
                        RiderMessageDeliveryStatus.read =>
                          Icons.done_all_rounded,
                        RiderMessageDeliveryStatus.delivered =>
                          Icons.done_all_rounded,
                        RiderMessageDeliveryStatus.pending =>
                          Icons.schedule_rounded,
                        RiderMessageDeliveryStatus.failed =>
                          Icons.error_outline_rounded,
                        _ => Icons.check_rounded,
                      },
                      size: 16,
                      color: message.isFailed
                          ? AgrisellColors.statusRedText
                          : AgrisellColors.authGreen,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      sentByRider ? '$time · ${_statusLabel(message)}' : time,
                      style: RiderChatMessagesStyles.textStyle2,
                    ),
                  ),
                ],
              ),
              if (onRetry != null)
                TextButton(
                  onPressed: () => onRetry!(),
                  child: const Text('Retry'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String riderMessageText(RiderChatMessage message) {
  if (message.body.isNotEmpty) return message.body;
  return switch (message.kind) {
    RiderMessageKind.location => 'Shared delivery location',
    RiderMessageKind.photo => 'Shared delivery photo',
    RiderMessageKind.deliveryUpdate ||
    RiderMessageKind.system => 'Delivery update',
    RiderMessageKind.text => '',
  };
}

String _statusLabel(RiderChatMessage message) => switch (message.status) {
  RiderMessageDeliveryStatus.pending => 'Waiting to synchronize',
  RiderMessageDeliveryStatus.sent => 'Sent',
  RiderMessageDeliveryStatus.delivered => 'Delivered',
  RiderMessageDeliveryStatus.read => 'Read',
  RiderMessageDeliveryStatus.failed => 'Failed - Retry',
};
