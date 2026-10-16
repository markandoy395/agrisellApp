import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/rider_communication_state.dart';
import '../controllers/rider_messages_controller.dart';
import '../styles/rider_messaging_design_styles.dart';

class RiderMessagesStatus extends StatelessWidget {
  const RiderMessagesStatus({
    required this.controller,
    required this.onRetry,
    super.key,
  });
  final RiderMessagesController controller;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final pending = controller.pendingTextMessages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state != RiderCommunicationLoadState.ready)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: state == RiderCommunicationLoadState.offline
                ? RiderMessagingDesignStyles.warning
                : RiderMessagingDesignStyles.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      state == RiderCommunicationLoadState.offline
                          ? Icons.wifi_off_rounded
                          : Icons.info_outline_rounded,
                      color: AgrisellColors.authGreen,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(switch (state) {
                        RiderCommunicationLoadState.loading =>
                          'Loading conversations',
                        RiderCommunicationLoadState.offline =>
                          'Messages are offline',
                        _ => 'Messages unavailable',
                      }, style: RiderMessagingDesignStyles.title),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (state == RiderCommunicationLoadState.loading)
                  const LinearProgressIndicator()
                else ...[
                  Text(
                    state == RiderCommunicationLoadState.offline
                        ? 'Reconnect to receive protected delivery messages. Pending text messages sync when online.'
                        : controller.errorMessage ?? 'Please try again.',
                    style: RiderMessagingDesignStyles.muted,
                  ),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
        if (pending.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: RiderMessagingDesignStyles.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending delivery messages · ${pending.length}',
                  style: RiderMessagingDesignStyles.title,
                ),
                for (final message in pending) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      Icon(
                        message.isFailed
                            ? Icons.error_outline_rounded
                            : Icons.schedule_rounded,
                        color: message.isFailed
                            ? AgrisellColors.statusRedText
                            : AgrisellColors.accentOrange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.isFailed
                                  ? 'Failed - Retry'
                                  : 'Waiting to synchronize',
                              style: RiderMessagingDesignStyles.body,
                            ),
                            Text(
                              message.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: RiderMessagingDesignStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      if (message.isFailed)
                        TextButton(
                          onPressed: () =>
                              controller.retryFailedMessage(message.id),
                          child: const Text('Retry'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class RiderMessagesEmpty extends StatelessWidget {
  const RiderMessagesEmpty({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: RiderMessagingDesignStyles.card,
    child: Column(
      children: [
        const CircleAvatar(
          radius: 36,
          backgroundColor: AgrisellColors.forestSoft,
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            color: AgrisellColors.authGreen,
            size: 34,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No delivery conversations',
          textAlign: TextAlign.center,
          style: RiderMessagingDesignStyles.title,
        ),
        const SizedBox(height: 10),
        Text(
          'Messages from sellers, buyers, and support will appear here. Try another filter if needed.',
          textAlign: TextAlign.center,
          style: RiderMessagingDesignStyles.muted,
        ),
      ],
    ),
  );
}
