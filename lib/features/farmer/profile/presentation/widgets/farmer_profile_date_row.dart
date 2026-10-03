import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_profile_edit_fields_styles.dart';

class FarmerProfileDateRow extends StatelessWidget {
  const FarmerProfileDateRow({
    required this.birthDate,
    required this.onBirthDateChanged,
    super.key,
  });

  final ProfileBirthDate birthDate;
  final ValueChanged<ProfileBirthDate> onBirthDateChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Date of birth',
        style: FarmerProfileEditFieldsStyles.labelStyle,
      ),
      FarmerProfileEditFieldsStyles.smallSpacing,
      Row(
        children: [
          Expanded(
            flex: 2,
            child: _dateSelect(
              'Day',
              birthDate.day,
              [for (var d = 1; d <= birthDate.maxDay; d++) (d, '$d')],
              (d) => onBirthDateChanged(birthDate.copyWith(day: d)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: _dateSelect(
              'Month',
              birthDate.month,
              [
                for (var m = 1; m <= 12; m++)
                  (m, ProfileBirthDate.months[m - 1]),
              ],
              (m) => onBirthDateChanged(birthDate.copyWith(month: m)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _dateSelect(
              'Year',
              birthDate.year,
              [for (var y = DateTime.now().year; y >= 1900; y--) (y, '$y')],
              (y) => onBirthDateChanged(birthDate.copyWith(year: y)),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _dateSelect(
    String label,
    int? value,
    List<(int, String)> options,
    ValueChanged<int> onChanged,
  ) => DropdownButtonFormField<int>(
    key: ValueKey('farmer-birth-$label-$value'),
    initialValue: value,
    isExpanded: true,
    menuMaxHeight: 280,
    style: FarmerProfileEditFieldsStyles.dropdownItemStyle,
    icon: const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: FarmerProfileEditFieldsStyles.dropdownIconColor,
      size: 18,
    ),
    decoration: FarmerProfileEditFieldsStyles.dateDropdownDecoration(),
    hint: Text(label),
    items: [
      for (final option in options)
        DropdownMenuItem(
          value: option.$1,
          child: Text(option.$2, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}
