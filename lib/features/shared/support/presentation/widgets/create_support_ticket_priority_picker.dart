import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import '../styles/create_support_ticket_styles.dart';

/// Priority selection widget displaying priority options as styled chips.
class CreateSupportTicketPriorityPicker extends StatelessWidget {
  const CreateSupportTicketPriorityPicker({
    required this.selectedPriority,
    required this.onPrioritySelected,
    super.key,
  });

  final SupportTicketPriority selectedPriority;
  final ValueChanged<SupportTicketPriority> onPrioritySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: CreateSupportTicketStyles.sectionHeading,
        ),
        const SizedBox(height: CreateSupportTicketStyles.chipSpacing),
        Row(
          children: SupportTicketPriority.values.map((pri) {
            final isSelected = selectedPriority == pri;
            return Padding(
              padding: const EdgeInsets.only(
                right: CreateSupportTicketStyles.chipRightMargin,
              ),
              child: ChoiceChip(
                label: Text(pri.label),
                selected: isSelected,
                selectedColor: pri.backgroundColor,
                backgroundColor: CreateSupportTicketStyles.surfaceColor,
                labelStyle: CreateSupportTicketStyles.priorityChipLabel(
                  isSelected: isSelected,
                  textColor: pri.textColor,
                ),
                shape: CreateSupportTicketStyles.priorityChipShape(
                  isSelected: isSelected,
                  activeColor: pri.textColor,
                ),
                onSelected: (selected) {
                  if (selected) onPrioritySelected(pri);
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
