import 'package:agresell_app/features/farmer/products/presentation/styles/product_edit_form_actions_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class ProductEditFormActions extends StatelessWidget {
  const ProductEditFormActions({
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ProductEditActionButton(label: 'Cancel', onPressed: onCancel),
        const SizedBox(width: 26),
        _ProductEditActionButton(
          label: 'Save',
          onPressed: onSave,
          isPrimary: true,
        ),
      ],
    );
  }
}

class _ProductEditActionButton extends StatelessWidget {
  const _ProductEditActionButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      height: 38,
      child: isPrimary ? _filledButton() : _outlinedButton(),
    );
  }

  Widget _filledButton() {
    return FilledButton(
      onPressed: onPressed,
      style: ProductEditFormActionsStyles.filledButtonStyle,
      child: _ButtonLabel(
        label: label,
        color: AgrisellColors.surface,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _outlinedButton() {
    return OutlinedButton(
      onPressed: onPressed,
      style: ProductEditFormActionsStyles.outlinedButtonStyle,
      child: _ButtonLabel(
        label: label,
        color: AgrisellColors.authGreen,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.label,
    required this.color,
    required this.fontWeight,
  });

  final String label;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: ProductEditFormActionsStyles.labelText(color, fontWeight),
    );
  }
}
