import 'package:flutter/material.dart';

import '../styles/cash_out_dialog_styles.dart';
import '../controllers/farmer_cash_out_form_controller.dart';
import 'cash_out_form_fields.dart';
import 'cash_out_form_actions.dart';

class CashOutDialogForm extends StatelessWidget {
  const CashOutDialogForm({
    super.key,
    required this.form,
    required this.onSubmit,
  });
  final FarmerCashOutFormController form;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Container(
    decoration: CashOutDialogStyles.sheet,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: CashOutDialogStyles.keyboardPadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: CashOutDialogStyles.formConstraints,
            child: SingleChildScrollView(
              padding: CashOutDialogStyles.formPadding,
              child: Form(
                key: form.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: CashOutDialogStyles.handleMargin,
                        decoration: CashOutDialogStyles.dragHandle,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: CashOutDialogStyles.headerIconPadding,
                          decoration: CashOutDialogStyles.headerIcon,
                          child: const Icon(
                            Icons.payments_rounded,
                            color: CashOutDialogStyles.green,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Request Cash Out',
                            style: CashOutDialogStyles.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: CashOutDialogStyles.closePadding,
                          constraints: CashOutDialogStyles.closeConstraints,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Submit a payout request to disburse your farm earnings.',
                      style: CashOutDialogStyles.description,
                    ),
                    const SizedBox(height: 18),
                    if (form.errorMessage != null) ...[
                      Container(
                        padding: CashOutDialogStyles.errorPadding,
                        decoration: CashOutDialogStyles.errorPanel,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 18,
                              color: CashOutDialogStyles.errorColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                form.errorMessage!,
                                style: CashOutDialogStyles.errorText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    CashOutFormFields(form: form),
                    const SizedBox(height: 22),
                    CashOutFormActions(
                      isSubmitting: form.isSubmitting,
                      onSubmit: onSubmit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
