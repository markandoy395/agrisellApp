import 'package:flutter/material.dart';

import '../styles/create_support_ticket_styles.dart';

/// Information banner detailing support response times and service expectations.
class CreateSupportTicketInfoCard extends StatelessWidget {
  const CreateSupportTicketInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: CreateSupportTicketStyles.infoCardPadding,
      decoration: CreateSupportTicketStyles.infoCardDecoration,
      child: Row(
        children: [
          const Icon(
            Icons.headset_mic_rounded,
            color: CreateSupportTicketStyles.primaryGreen,
            size: CreateSupportTicketStyles.infoIconSize,
          ),
          const SizedBox(width: CreateSupportTicketStyles.infoContentSpacing),
          Expanded(
            child: Text(
              'Our customer support team is here to assist you. Typical response time is under 15 minutes.',
              style: CreateSupportTicketStyles.infoText,
            ),
          ),
        ],
      ),
    );
  }
}
