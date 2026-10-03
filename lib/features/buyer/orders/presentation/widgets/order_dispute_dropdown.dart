import 'package:flutter/material.dart';

import '../styles/order_dispute_styles.dart';

class OrderDisputeDropdown<T> extends StatelessWidget {
  const OrderDisputeDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.labelForValue,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T) labelForValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: OrderDisputeStyles.fieldLabel),
      const SizedBox(height: 8),
      DropdownButtonFormField<T>(
        initialValue: value,
        decoration: OrderDisputeStyles.dropdownDecoration,
        items: [
          for (final option in values)
            DropdownMenuItem(
              value: option,
              child: Text(
                labelForValue(option),
                style: OrderDisputeStyles.dropdownText,
              ),
            ),
        ],
        onChanged: (selected) {
          if (selected != null) onChanged(selected);
        },
      ),
    ],
  );
}
