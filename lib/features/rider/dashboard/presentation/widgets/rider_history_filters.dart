import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';

class RiderHistoryFilterChips extends StatelessWidget {
  const RiderHistoryFilterChips({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final RiderHistoryStatus? selected;
  final ValueChanged<RiderHistoryStatus?> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      ChoiceChip(
        label: const Text('All'),
        selected: selected == null,
        onSelected: (_) => onChanged(null),
      ),
      for (final status in RiderHistoryStatus.values)
        ChoiceChip(
          label: Text(status.label),
          selected: selected == status,
          onSelected: (_) => onChanged(status),
        ),
    ],
  );
}
