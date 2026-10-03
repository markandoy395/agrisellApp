import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_request_filter_sheet_styles.dart';

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
      Text(label, style: RiderRequestFilterSheetStyles.sectionLabelStyle),
      Wrap(
        spacing: RiderRequestFilterSheetStyles.chipSpacing,
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

class RiderDoubleFilterChoices extends StatelessWidget {
  const RiderDoubleFilterChoices({
    required this.label,
    required this.value,
    required this.values,
    required this.formatLabel,
    required this.onChanged,
    super.key,
  });

  final String label;
  final double? value;
  final List<double> values;
  final String Function(double value) formatLabel;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: RiderRequestFilterSheetStyles.sectionLabelStyle),
      Wrap(
        spacing: RiderRequestFilterSheetStyles.chipSpacing,
        children: [
          for (final item in <double?>[null, ...values])
            ChoiceChip(
              label: Text(item == null ? 'Any' : formatLabel(item)),
              selected: value == item,
              onSelected: (_) => onChanged(item),
            ),
        ],
      ),
    ],
  );
}
