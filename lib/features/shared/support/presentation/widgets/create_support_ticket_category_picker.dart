import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import '../styles/create_support_ticket_styles.dart';

/// Category selection widget presenting options as selectable choice chips.
class CreateSupportTicketCategoryPicker extends StatelessWidget {
  const CreateSupportTicketCategoryPicker({
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final SupportTicketCategory selectedCategory;
  final ValueChanged<SupportTicketCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: CreateSupportTicketStyles.sectionHeading,
        ),
        const SizedBox(height: CreateSupportTicketStyles.chipSpacing),
        Wrap(
          spacing: CreateSupportTicketStyles.chipSpacing,
          runSpacing: CreateSupportTicketStyles.chipRunSpacing,
          children: SupportTicketCategory.values.map((cat) {
            final isSelected = selectedCategory == cat;
            return ChoiceChip(
              avatar: Icon(
                cat.icon,
                size: CreateSupportTicketStyles.chipAvatarSize,
                color: isSelected
                    ? Colors.white
                    : CreateSupportTicketStyles.headingTextColor,
              ),
              label: Text(cat.label),
              selected: isSelected,
              selectedColor: CreateSupportTicketStyles.primaryGreen,
              backgroundColor: CreateSupportTicketStyles.surfaceColor,
              labelStyle: CreateSupportTicketStyles.categoryChipLabel(isSelected),
              shape: CreateSupportTicketStyles.categoryChipShape(isSelected),
              onSelected: (selected) {
                if (selected) onCategorySelected(cat);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
