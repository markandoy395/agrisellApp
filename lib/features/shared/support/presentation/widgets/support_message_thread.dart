import 'package:flutter/material.dart';

import '../styles/support_ticket_detail_styles.dart';
import '../controllers/support_ticket_detail_controller.dart';
import 'support_message_bubble.dart';

class SupportMessageThread extends StatelessWidget {
  const SupportMessageThread({
    super.key,
    required this.controller,
    required this.scrollController,
  });
  final SupportTicketDetailController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final messages = controller.messages;
    return controller.isLoading && messages.isEmpty
        ? const Center(
            child: CircularProgressIndicator(
              color: SupportTicketDetailStyles.green,
            ),
          )
        : controller.errorMessage != null && messages.isEmpty
        ? Center(
            child: Padding(
              padding: SupportTicketDetailStyles.errorPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: SupportTicketDetailStyles.threadError,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: controller.loadMessages,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          )
        : RefreshIndicator(
            color: SupportTicketDetailStyles.green,
            onRefresh: controller.loadMessages,
            child: ListView.builder(
              controller: scrollController,
              padding: SupportTicketDetailStyles.threadPadding,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return SupportMessageBubble(message: msg);
              },
            ),
          );
  }
}
