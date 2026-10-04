import 'package:flutter/material.dart';
import '../styles/create_support_ticket_styles.dart';

class CreateSupportTicketInfoCard extends StatelessWidget {
  const CreateSupportTicketInfoCard({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: CreateSupportTicketStyles.infoCardPadding,
    decoration: CreateSupportTicketStyles.infoCardDecoration,
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: CreateSupportTicketStyles.infoIconDecoration,
          child: const Icon(
            Icons.headset_mic_outlined,
            color: CreateSupportTicketStyles.primaryGreen,
            size: CreateSupportTicketStyles.infoIconSize,
          ),
        ),
        const SizedBox(width: CreateSupportTicketStyles.infoContentSpacing),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our customer support team is here to assist you.',
                style: CreateSupportTicketStyles.infoText,
              ),
              SizedBox(height: 4),
              Text(
                'Typical response time is under 15 minutes.',
                style: CreateSupportTicketStyles.description,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
