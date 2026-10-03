import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

import '../styles/rider_withdrawal_control_styles.dart';
import '../styles/rider_withdrawal_styles.dart';
import '../utils/rider_withdrawal_validation.dart';
import 'rider_withdrawal_form_controls.dart';

class RiderWithdrawalMethodForm extends StatelessWidget {
  const RiderWithdrawalMethodForm({
    required this.formKey,
    required this.accountNameController,
    required this.accountNumberController,
    required this.bankNameController,
    required this.payoutMethod,
    required this.isDefault,
    required this.isSaving,
    required this.onPayoutMethodChanged,
    required this.onDefaultChanged,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController accountNameController;
  final TextEditingController accountNumberController;
  final TextEditingController bankNameController;
  final String payoutMethod;
  final bool isDefault;
  final bool isSaving;
  final ValueChanged<String> onPayoutMethodChanged;
  final ValueChanged<bool> onDefaultChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isGcash = payoutMethod == 'gcash';

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: RiderWithdrawalStyles.alignStart,
        children: [
          const Text('Account Type', style: RiderWithdrawalStyles.fieldLabel),
          const SizedBox(height: RiderWithdrawalStyles.inlineGap),
          Row(
            children: [
              Expanded(
                child: RiderWithdrawalTypeButton(
                  title: 'GCash',
                  icon: Icons.phone_android_rounded,
                  isSelected: isGcash,
                  onTap: () => onPayoutMethodChanged('gcash'),
                ),
              ),
              const SizedBox(width: RiderWithdrawalStyles.itemGap),
              Expanded(
                child: RiderWithdrawalTypeButton(
                  title: 'Bank Account',
                  icon: Icons.account_balance_rounded,
                  isSelected: payoutMethod == 'bank_transfer',
                  onTap: () => onPayoutMethodChanged('bank_transfer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: RiderWithdrawalStyles.fieldGap),
          _WithdrawalAccountField(
            label: 'Account Name',
            hint: 'Full name on account',
            controller: accountNameController,
            textCapitalization: TextCapitalization.words,
            validator: validateWithdrawalAccountName,
          ),
          const SizedBox(height: RiderWithdrawalStyles.fieldGap),
          _WithdrawalAccountField(
            label: isGcash ? 'GCash Mobile Number' : 'Bank Account Number',
            hint: isGcash ? '09XXXXXXXXX' : 'Account number',
            controller: accountNumberController,
            keyboardType: TextInputType.phone,
            validator: (value) =>
                validateWithdrawalAccountNumber(value, payoutMethod),
          ),
          if (payoutMethod == 'bank_transfer') ...[
            const SizedBox(height: RiderWithdrawalStyles.fieldGap),
            _WithdrawalAccountField(
              label: 'Bank Name',
              hint: 'e.g. BDO, BPI, Landbank, UnionBank',
              controller: bankNameController,
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  validateWithdrawalBankName(value, payoutMethod),
            ),
          ],
          const SizedBox(height: RiderWithdrawalStyles.fieldGap),
          SwitchListTile(
            contentPadding: RiderWithdrawalStyles.switchPadding,
            title: const Text(
              'Set as default withdrawal method',
              style: RiderWithdrawalStyles.fieldLabel,
            ),
            value: isDefault,
            activeThumbColor: AgrisellColors.authGreen,
            onChanged: onDefaultChanged,
          ),
          const SizedBox(height: RiderWithdrawalStyles.sectionGap),
          RiderWithdrawalFormActions(
            isSaving: isSaving,
            onCancel: onCancel,
            onSave: onSave,
          ),
        ],
      ),
    );
  }
}

class _WithdrawalAccountField extends StatelessWidget {
  const _WithdrawalAccountField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: RiderWithdrawalStyles.alignStart,
      children: [
        Text(label, style: RiderWithdrawalStyles.fieldLabel),
        const SizedBox(height: RiderWithdrawalStyles.labelGap),
        TextFormField(
          controller: controller,
          textCapitalization: textCapitalization,
          keyboardType: keyboardType,
          decoration: RiderWithdrawalControlStyles.accountInput(hint),
          validator: validator,
        ),
      ],
    );
  }
}
