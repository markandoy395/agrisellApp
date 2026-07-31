import 'package:flutter/material.dart';

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
            initialValue: _kind,
            items: [
              for (final kind in PickupProblemKind.values)
                DropdownMenuItem(value: kind, child: Text(kind.label)),
            ],
            onChanged: (value) => setState(() => _kind = value ?? _kind),
            decoration: const InputDecoration(labelText: 'Problem type'),
          ),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notes'),
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
