import 'package:agresell_app/features/shared/widgets/profile/profile_date_of_birth_row_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_edit_row_shell.dart';

class ProfileDateOfBirthRow extends StatelessWidget {
  const ProfileDateOfBirthRow({
    required this.value,
    required this.onDayChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    super.key,
  });

  final ProfileBirthDate value;
  final ValueChanged<int> onDayChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;

  @override
  Widget build(BuildContext context) {
    return ProfileEditRow(
      label: 'Date of Birth',
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _DateSelectPill<int>(
              key: const ValueKey('profile-birth-day-select'),
              value: value.day,
              placeholder: 'Day',
              options: [
                for (var day = 1; day <= value.maxDay; day++)
                  _DateSelectOption(value: day, label: '$day'),
              ],
              onChanged: onDayChanged,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 5,
            child: _DateSelectPill<int>(
              key: const ValueKey('profile-birth-month-select'),
              value: value.month,
              placeholder: 'Month',
              options: [
                for (
                  var month = 1;
                  month <= ProfileBirthDate.months.length;
                  month++
                )
                  _DateSelectOption(
                    value: month,
                    label: ProfileBirthDate.months[month - 1],
                  ),
              ],
              onChanged: onMonthChanged,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 3,
            child: _DateSelectPill<int>(
              key: const ValueKey('profile-birth-year-select'),
              value: value.year,
              placeholder: 'Year',
              options: [
                for (var year = DateTime.now().year; year >= 1900; year--)
                  _DateSelectOption(value: year, label: '$year'),
              ],
              onChanged: onYearChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelectPill<T> extends StatelessWidget {
  const _DateSelectPill({
    required this.value,
    required this.placeholder,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final T? value;
  final String placeholder;
  final List<_DateSelectOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final textStyle = ProfileDateOfBirthRowStyles.buttonStyle(context);
    var selectedLabel = placeholder;
    for (final option in options) {
      if (option.value == value) {
        selectedLabel = option.label;
        break;
      }
    }

    return PopupMenuButton<T>(
      initialValue: value,
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      tooltip: '',
      color: AgrisellColors.surface,
      constraints: const BoxConstraints(maxHeight: 260, minWidth: 72),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: onChanged,
      itemBuilder: (context) {
        return [
          for (final option in options)
            PopupMenuItem<T>(
              value: option.value,
              child: Text(option.label, style: textStyle),
            ),
        ];
      },
      child: ProfileEditPill(
        horizontalPadding: 4,
        child: Row(
          children: [
            Expanded(child: _DateSelectLabel(selectedLabel, style: textStyle)),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AgrisellColors.authGreen,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSelectOption<T> {
  const _DateSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

class _DateSelectLabel extends StatelessWidget {
  const _DateSelectLabel(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}
