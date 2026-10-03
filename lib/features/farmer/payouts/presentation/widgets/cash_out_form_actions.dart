import 'package:flutter/material.dart';

import '../styles/cash_out_dialog_styles.dart';

class CashOutFormActions extends StatelessWidget {
  const CashOutFormActions({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
  });
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
          style: CashOutDialogStyles.cancelButton,
          child: const Text('Cancel', style: CashOutDialogStyles.cancelText),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          onPressed: isSubmitting ? null : onSubmit,
          style: CashOutDialogStyles.submitButton,
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CashOutDialogStyles.white,
                  ),
                )
              : const Text(
                  'Submit Request',
                  style: CashOutDialogStyles.submitText,
                ),
        ),
      ),
    ],
  );
}
