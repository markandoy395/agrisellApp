import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/features/shared/widgets/profile/account_edit_fields_styles.dart';

class AccountEditTextField extends StatelessWidget {
  const AccountEditTextField({
    required this.label,
    required this.controller,
    this.optional = false,
    this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final bool optional;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(label, style: AccountEditFieldsStyles.labelStyle),
          ),
          if (optional)
            const Text(
              'Optional',
              style: AccountEditFieldsStyles.optionalStyle,
            ),
        ],
      ),
      AccountEditFieldsStyles.smallSpacing,
      Semantics(
        label: label,
        child: TextField(
          key: ValueKey('account-edit-$label'),
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: keyboardType == null
              ? TextCapitalization.words
              : TextCapitalization.none,
          style: AccountEditFieldsStyles.inputStyle,
          decoration: AccountEditFieldsStyles.decoration(hint: hint, icon: icon),
        ),
      ),
    ],
  );
}
