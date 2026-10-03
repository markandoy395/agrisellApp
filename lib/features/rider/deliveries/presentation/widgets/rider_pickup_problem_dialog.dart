import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_pickup_problem_dialog_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';

class PickupProblemDraft {
  const PickupProblemDraft({required this.kind, required this.notes});
  final PickupProblemKind kind;
  final String notes;
}

class RiderPickupProblemDialog extends StatefulWidget {
  const RiderPickupProblemDialog({super.key});

  @override
  State<RiderPickupProblemDialog> createState() =>
      _RiderPickupProblemDialogState();
}

class _RiderPickupProblemDialogState extends State<RiderPickupProblemDialog> {
  var _kind = PickupProblemKind.productNotReady;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Report pickup problem'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<PickupProblemKind>(
            dropdownColor: AppDropdownStyle.menuColor,
            borderRadius: AppDropdownStyle.menuBorderRadius,
            style: AppDropdownStyle.textStyle,
            iconEnabledColor: AppDropdownStyle.iconColor,
            initialValue: _kind,
            items: [
              for (final kind in PickupProblemKind.values)
                DropdownMenuItem(value: kind, child: Text(kind.label)),
            ],
            onChanged: (value) => setState(() => _kind = value ?? _kind),
            decoration: RiderPickupProblemDialogStyles.inputDecoration,
          ),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 4,
            decoration: RiderPickupProblemDialogStyles.inputDecoration2,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final notes = _notes.text.trim();
          if (notes.isEmpty) return;
          Navigator.of(
            context,
          ).pop(PickupProblemDraft(kind: _kind, notes: notes));
        },
        child: const Text('Save problem'),
      ),
    ],
  );
}

Future<PickupProblemDraft?> showRiderPickupProblemDialog(
  BuildContext context,
) => showDialog<PickupProblemDraft>(
  context: context,
  builder: (_) => const RiderPickupProblemDialog(),
);
