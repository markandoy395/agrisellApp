import 'package:flutter/material.dart';

import '../styles/create_support_ticket_styles.dart';

/// Form text inputs for the support ticket subject and detailed inquiry message.
class CreateSupportTicketFormFields extends StatelessWidget {
  const CreateSupportTicketFormFields({
    required this.subjectController,
    required this.messageController,
    super.key,
  });

  final TextEditingController subjectController;
  final TextEditingController messageController;

  static String? validateSubject(String? val) {
    final text = val?.trim() ?? '';
    if (text.length < 2) {
      return 'Subject must be at least 2 characters long.';
    }
    if (text.length > 255) {
      return 'Subject cannot exceed 255 characters.';
    }
    return null;
  }

  static String? validateMessage(String? val) {
    final text = val?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please describe your inquiry or issue.';
    }
    if (text.length > 4000) {
      return 'Message cannot exceed 4000 characters.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject Field
        const Text(
          'Subject',
          style: CreateSupportTicketStyles.sectionHeading,
        ),
        const SizedBox(height: CreateSupportTicketStyles.fieldLabelSpacing),
        TextFormField(
          controller: subjectController,
          maxLength: 255,
          decoration: CreateSupportTicketStyles.inputDecoration(
            hintText: 'Brief summary of your inquiry...',
            hasCounter: true,
          ),
          validator: validateSubject,
        ),
        const SizedBox(height: CreateSupportTicketStyles.sectionSpacing),

        // Message Field
        const Text(
          'Message',
          style: CreateSupportTicketStyles.sectionHeading,
        ),
        const SizedBox(height: CreateSupportTicketStyles.fieldLabelSpacing),
        TextFormField(
          controller: messageController,
          minLines: 4,
          maxLines: 8,
          maxLength: 4000,
          decoration: CreateSupportTicketStyles.inputDecoration(
            hintText: 'Provide details, context, or questions for our support team...',
            hasCounter: false,
          ),
          validator: validateMessage,
        ),
      ],
    );
  }
}
