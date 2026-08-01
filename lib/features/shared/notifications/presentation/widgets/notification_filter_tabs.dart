import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';

class NotificationFilterTabs extends StatelessWidget {
  const NotificationFilterTabs({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: NotificationFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = NotificationFilter.values[index];
          final isSelected = filter == selected;
          return Semantics(
            button: true,
            selected: isSelected,
            label: 'Show ${filter.label.toLowerCase()} notifications',
            child: ChoiceChip(
              label: Text(filter.label),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => onSelected(filter),
              backgroundColor: AgrisellColors.surface,
              selectedColor: AgrisellColors.authGreen,
              side: BorderSide(
                color: isSelected
                    ? AgrisellColors.authGreen
                    : AgrisellColors.borderLine,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? AgrisellColors.surface
                    : AgrisellColors.headingGreen,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}
