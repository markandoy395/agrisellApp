import 'package:flutter/material.dart';
import '../../domain/pickup_confirmation.dart';
import '../styles/rider_pickup_design_styles.dart';
import 'rider_pickup_problem_options.dart';

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
  String? _error;
  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final notes = _notes.text.trim();
    if (notes.isEmpty || notes.length > 500) {
      setState(() => _error = 'Add notes of up to 500 characters.');
      return;
    }
    Navigator.pop(context, PickupProblemDraft(kind: _kind, notes: notes));
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        0,
        18,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Report pickup problem',
                  style: RiderPickupDesignStyles.title,
                ),
              ),
              IconButton(
                tooltip: 'Close pickup problem',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: RiderPickupDesignStyles.error),
            ),
          Expanded(
            child: ListView(
              children: [
                Text(
                  'Tell us what happened with this pickup so we can help resolve the issue.',
                  style: RiderPickupDesignStyles.caption,
                ),
                const SizedBox(height: 20),
                Text('Problem type *', style: RiderPickupDesignStyles.body),
                const SizedBox(height: 8),
                RiderPickupProblemOptions(
                  selected: _kind,
                  onChanged: (kind) => setState(() => _kind = kind),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _notes,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  style: RiderPickupDesignStyles.body,
                  decoration: RiderPickupDesignStyles.input(
                    'Notes *',
                    hint: 'Add more details about the problem...',
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: OutlinedButton(
                  style: RiderPickupDesignStyles.cancel,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: RiderPickupDesignStyles.primary,
                  onPressed: _save,
                  child: const Text('Save problem'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Future<PickupProblemDraft?> showRiderPickupProblemDialog(
  BuildContext context,
) => showModalBottomSheet<PickupProblemDraft>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => const FractionallySizedBox(
    heightFactor: .92,
    child: RiderPickupProblemDialog(),
  ),
);
