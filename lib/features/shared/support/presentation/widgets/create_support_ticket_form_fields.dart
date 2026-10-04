import 'package:flutter/material.dart';
import 'create_support_ticket_message_field.dart';
import '../styles/create_support_ticket_styles.dart';

class CreateSupportTicketFormFields extends StatelessWidget {
  const CreateSupportTicketFormFields({
    required this.subjectController,
    required this.messageController,
    super.key,
  });
  final TextEditingController subjectController;
  final TextEditingController messageController;

  static String? validateSubject(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 2) return 'Subject must be at least 2 characters long.';
    if (text.length > 255) return 'Subject cannot exceed 255 characters.';
    return null;
  }

  static String? validateMessage(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please describe your inquiry or issue.';
    if (text.length > 4000) return 'Message cannot exceed 4000 characters.';
    return null;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Subject', style: CreateSupportTicketStyles.sectionHeading),
      const SizedBox(height: CreateSupportTicketStyles.fieldLabelSpacing),
      TextFormField(
        controller: subjectController,
        maxLength: 255,
        style: CreateSupportTicketStyles.fieldText,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.next,
        decoration: CreateSupportTicketStyles.inputDecoration(
          hintText: 'Brief summary of your inquiry...',
          hasCounter: true,
        ),
        validator: validateSubject,
      ),
      const SizedBox(height: CreateSupportTicketStyles.sectionSpacing),
      const Text('Message', style: CreateSupportTicketStyles.sectionHeading),
      const SizedBox(height: CreateSupportTicketStyles.fieldLabelSpacing),
      CreateSupportTicketMessageField(
        controller: messageController,
        validator: validateMessage,
      ),
    ],
  );
}
