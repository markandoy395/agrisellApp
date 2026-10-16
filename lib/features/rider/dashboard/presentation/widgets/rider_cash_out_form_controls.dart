import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:flutter/material.dart';

import '../styles/rider_cash_out_dialog_styles.dart';

class RiderCashOutErrorBanner extends StatelessWidget {
  const RiderCashOutErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: RiderCashOutDialogStyles.errorPadding,
      decoration: RiderCashOutDialogStyles.errorBannerDecoration,
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: RiderCashOutDialogStyles.errorIconSize,
            color: AgrisellColors.statusRedText,
          ),
          const SizedBox(width: RiderCashOutDialogStyles.errorContentGap),
          Expanded(
            child: Text(message, style: RiderCashOutDialogStyles.errorText),
          ),
        ],
      ),
    );
  }
}

class RiderCashOutNotesField extends StatelessWidget {
  const RiderCashOutNotesField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: RiderCashOutDialogStyles.sectionLabel,
        ),
        const SizedBox(height: RiderCashOutDialogStyles.inputLabelGap),
        TextFormField(
          controller: controller,
          maxLines: 2,
          decoration: RiderCashOutDialogStyles.inputDecoration(
            hintText: 'Add any notes for payout processing',
          ),
        ),
      ],
    );
  }
}

class RiderCashOutActions extends StatelessWidget {
  const RiderCashOutActions({
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onCancel,
            style: RiderCashOutDialogStyles.cancelButtonStyle,
            child: const Text(
              'Cancel',
              style: RiderCashOutDialogStyles.cancelButtonText,
            ),
          ),
        ),
        const SizedBox(width: RiderCashOutDialogStyles.buttonSpacing),
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: RiderCashOutDialogStyles.submitButtonStyle,
            child: isSubmitting
                ? const SizedBox(
                    width: RiderCashOutDialogStyles.spinnerSize,
                    height: RiderCashOutDialogStyles.spinnerSize,
                    child: CircularProgressIndicator(
                      strokeWidth: RiderCashOutDialogStyles.spinnerStroke,
                      color: AgrisellColors.surface,
                    ),
                  )
                : const Text(
                    'Submit Cash Out',
                    style: RiderCashOutDialogStyles.submitButtonText,
                  ),
          ),
        ),
      ],
    );
  }
}
