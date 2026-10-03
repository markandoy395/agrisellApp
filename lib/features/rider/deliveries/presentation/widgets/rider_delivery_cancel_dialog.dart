import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_delivery_cancel_dialog_styles.dart';
import 'package:flutter/material.dart';

Future<String?> showRiderCancellationReasonDialog(BuildContext context) async {
  final controller = TextEditingController();
  final reason = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancel delivery'),
      content: TextField(
        controller: controller,
        autofocus: true,
        minLines: 2,
        maxLines: 4,
        decoration: RiderDeliveryCancelDialogStyles.inputDecoration,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep delivery'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Confirm cancellation'),
        ),
      ],
    ),
  );
  controller.dispose();
  return reason == null || reason.isEmpty ? null : reason;
}
