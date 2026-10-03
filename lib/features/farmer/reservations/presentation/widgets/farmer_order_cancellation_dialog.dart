import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_order_cancellation_dialog_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';

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
          style: SharedPresentationStyles.titleExtraBold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone.',
              style: SharedPresentationStyles.caption,
            ),
            const SizedBox(height: 14),
            const Text(
              'Cancellation Reason:',
              style: SharedPresentationStyles.captionBold,
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
              decoration: FarmerOrderCancellationDialogStyles.inputDecoration,
              items: farmerOrderCancellationReasons
                  .map(
                    (reason) => DropdownMenuItem<String>(
                      value: reason,
                      child: Text(
                        reason,
                        overflow: TextOverflow.ellipsis,
                        style: SharedPresentationStyles.caption,
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
            style: FarmerOrderCancellationDialogStyles.filledButtonStyle,
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    ),
  );
}
