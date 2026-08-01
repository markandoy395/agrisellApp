import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class BasketSelectionCheckbox extends StatelessWidget {
  const BasketSelectionCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      label: label,
      child: SizedBox.square(
        dimension: 28,
        child: Checkbox(
          value: value,
          visualDensity: VisualDensity.compact,
          side: const BorderSide(color: AgrisellColors.checkboxBorder),
          activeColor: AgrisellColors.authGreen,
          onChanged: (checked) => onChanged(checked ?? false),
        ),
      ),
    );
  }
}
