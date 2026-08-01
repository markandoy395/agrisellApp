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
      style: FilledButton.styleFrom(
        backgroundColor: AgrisellColors.authGreen,
        foregroundColor: AgrisellColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
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
      style: OutlinedButton.styleFrom(
        foregroundColor: AgrisellColors.authGreen,
        side: const BorderSide(color: AgrisellColors.authGreen, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
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
      style: TextStyle(
        color: color,
        fontSize: 13,
        height: 1,
        fontWeight: fontWeight,
      ),
    );
  }
}
