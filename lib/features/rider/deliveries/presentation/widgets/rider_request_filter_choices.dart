import 'package:flutter/material.dart';

class RiderMinuteFilterChoices extends StatelessWidget {
  const RiderMinuteFilterChoices({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    super.key,
  });

  final String label;
  final int? value;
  final List<int> values;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      Wrap(
        spacing: 7,
        children: [
          for (final minutes in <int?>[null, ...values])
            ChoiceChip(
              label: Text(minutes == null ? 'Any' : '$minutes min'),
              selected: value == minutes,
              onSelected: (_) => onChanged(minutes),
            ),
        ],
      ),
    ],
  );
}
