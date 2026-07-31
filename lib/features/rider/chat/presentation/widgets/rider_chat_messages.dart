import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_messages_controller.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderMessageBody extends StatelessWidget {
  const RiderMessageBody({required this.controller, super.key});

  final RiderMessagesController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingMessages) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: RiderLoadingStateCard(
            title: 'Loading messages',
            message: 'Getting this delivery conversation ready.',
          ),
        ),
      );
    }
    if (controller.messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: RiderEmptyStateCard(
            title: 'No messages yet',
            message: 'Use the protected composer to start this conversation.',
            icon: Icons.forum_outlined,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      itemCount: controller.messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        return RiderMessageBubble(
          message: message,
          onRetry: message.isFailed
              ? () => controller.retryFailedMessage(message.id)
              : null,
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
    return Align(
      alignment: sentByRider ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 270),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: sentByRider
                ? AgrisellColors.authGreen
                : AgrisellColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: sentByRider
                ? null
                : Border.all(color: AgrisellColors.borderLine),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  riderMessageText(message),
                  style: TextStyle(
                    color: sentByRider
                        ? AgrisellColors.surface
                        : AgrisellColors.headingGreen,
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (sentByRider)
                  Text(
                    _statusLabel(message),
                    style: const TextStyle(
                      color: AgrisellColors.surface,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
