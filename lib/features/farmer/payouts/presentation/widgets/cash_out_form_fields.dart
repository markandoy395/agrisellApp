import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/farmer_cash_out_form_controller.dart';
import '../styles/cash_out_dialog_styles.dart';
import 'cash_out_form_field.dart';
import 'cash_out_method_card.dart';

class CashOutFormFields extends StatelessWidget {
  const CashOutFormFields({super.key, required this.form});
  final FarmerCashOutFormController form;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Payout Method', style: CashOutDialogStyles.fieldLabel),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: CashOutMethodCard(
              title: 'GCash',
              subtitle: 'Instant e-wallet',
              icon: Icons.phone_android_rounded,
              isSelected: !form.isBankTransfer,
              onTap: () => form.selectMethod('gcash'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CashOutMethodCard(
              title: 'Bank Transfer',
              subtitle: 'Direct to account',
              icon: Icons.account_balance_rounded,
              isSelected: form.isBankTransfer,
              onTap: () => form.selectMethod('bank_transfer'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      CashOutFormField(
        label: 'Cash-Out Amount (\u20b1)',
        controller: form.amount,
        hintText: 'Enter amount (e.g. 1000)',
        isAmount: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        validator: form.validateAmount,
      ),
      const SizedBox(height: 14),
      CashOutFormField(
        label: 'Account Name',
        controller: form.accountName,
        hintText: 'Full name on account',
        textCapitalization: TextCapitalization.words,
        validator: form.validateAccountName,
      ),
      const SizedBox(height: 14),
      CashOutFormField(
        label: form.isBankTransfer
            ? 'Bank Account Number'
            : 'GCash Mobile Number',
        controller: form.accountNumber,
        hintText: form.isBankTransfer ? 'Account number' : '09XXXXXXXXX',
        keyboardType: TextInputType.phone,
        validator: form.validateAccountNumber,
      ),
      if (form.isBankTransfer) ...[
        const SizedBox(height: 14),
        CashOutFormField(
          label: 'Bank Name',
          controller: form.bankName,
          hintText: 'e.g. BDO, BPI, Landbank, UnionBank',
          textCapitalization: TextCapitalization.words,
          validator: form.validateBankName,
        ),
      ],
      const SizedBox(height: 14),
      CashOutFormField(
        label: 'Notes (Optional)',
        controller: form.notes,
        hintText: 'Add any notes for admin review',
        maxLines: 2,
      ),
    ],
  );
}
