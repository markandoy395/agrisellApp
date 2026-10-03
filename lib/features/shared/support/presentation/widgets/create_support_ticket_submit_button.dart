import 'package:flutter/material.dart';

import '../styles/create_support_ticket_styles.dart';

/// Full-width submit button displaying a loading spinner during asynchronous operations.
class CreateSupportTicketSubmitButton extends StatelessWidget {
  const CreateSupportTicketSubmitButton({
    required this.isSubmitting,
    required this.onPressed,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: CreateSupportTicketStyles.submitButtonHeight,
      child: FilledButton(
        onPressed: isSubmitting ? null : onPressed,
        style: CreateSupportTicketStyles.submitButtonStyle,
        child: isSubmitting
            ? const SizedBox(
                width: CreateSupportTicketStyles.submitIndicatorSize,
                height: CreateSupportTicketStyles.submitIndicatorSize,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: CreateSupportTicketStyles.submitIndicatorStroke,
                ),
              )
            : const Text(
                'Submit Support Ticket',
                style: CreateSupportTicketStyles.submitButtonText,
              ),
      ),
    );
  }
}
