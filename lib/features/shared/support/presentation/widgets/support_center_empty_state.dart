import 'package:flutter/material.dart';

import '../styles/support_center_styles.dart';

class SupportCenterEmptyState extends StatelessWidget {
  const SupportCenterEmptyState({
    required this.isSearchingOrFiltering,
    required this.onOpenCreateTicket,
    super.key,
  });

  final bool isSearchingOrFiltering;
  final VoidCallback onOpenCreateTicket;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: SupportCenterStyles.emptyPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: SupportCenterStyles.emptyBadgeSize,
              height: SupportCenterStyles.emptyBadgeSize,
              decoration: SupportCenterStyles.emptyBadgeDecoration,
              child: const Icon(
                Icons.support_agent_rounded,
                size: SupportCenterStyles.emptyIconSize,
                color: SupportCenterStyles.emptyIconColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearchingOrFiltering
                  ? 'No matching tickets found'
                  : 'No support tickets opened yet',
              style: SupportCenterStyles.emptyTitleStyle,
            ),
            const SizedBox(height: 8),
            Text(
              isSearchingOrFiltering
                  ? 'Try adjusting your search terms or filter tab.'
                  : 'Have an inquiry or issue regarding orders, payments, or safety? We are ready to help.',
              textAlign: TextAlign.center,
              style: SupportCenterStyles.emptySubtitleStyle,
            ),
            if (!isSearchingOrFiltering) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onOpenCreateTicket,
                style: SupportCenterStyles.openFirstTicketButtonStyle,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Open Your First Ticket'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
