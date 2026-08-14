import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

const farmerOrderCancellationReasons = <String>[
  'Out of stock',
  'Product unavailable',
  'Unable to fulfill on time',
  'Farm emergency',
  'Other operational issue',
];

Future<String?> showFarmerOrderCancellationDialog(BuildContext context) {
  String? selectedReason;
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text(
          'Cancel Order?',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 14),
            const Text(
              'Cancellation Reason:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              dropdownColor: AppDropdownStyle.menuColor,
              borderRadius: AppDropdownStyle.menuBorderRadius,
              style: AppDropdownStyle.textStyle,
              iconEnabledColor: AppDropdownStyle.iconColor,
              key: const ValueKey('farmer-cancellation-reason'),
              initialValue: selectedReason,
              isExpanded: true,
              decoration: const InputDecoration(
                hintText: 'Select reason',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: farmerOrderCancellationReasons
                  .map(
                    (reason) => DropdownMenuItem<String>(
                      value: reason,
                      child: Text(
                        reason,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (reason) =>
                  setDialogState(() => selectedReason = reason),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            key: const ValueKey('confirm-farmer-order-cancellation'),
            onPressed: selectedReason == null
                ? null
                : () => Navigator.of(context).pop(selectedReason),
            style: FilledButton.styleFrom(
              backgroundColor: AgrisellColors.statusRedText,
              foregroundColor: AgrisellColors.surface,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    ),
  );
}
