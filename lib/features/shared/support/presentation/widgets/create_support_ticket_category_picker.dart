import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import '../styles/create_support_ticket_styles.dart';
import '../styles/create_support_ticket_selection_styles.dart';

class CreateSupportTicketCategoryPicker extends StatelessWidget {
  const CreateSupportTicketCategoryPicker({
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });
  final SupportTicketCategory selectedCategory;
  final ValueChanged<SupportTicketCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Category', style: CreateSupportTicketStyles.sectionHeading),
      const SizedBox(height: 4),
      const Text(
        'Select the category that best matches your issue.',
        style: CreateSupportTicketStyles.description,
      ),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 10,
          runSpacing: 10,
          children: SupportTicketCategory.values.map((category) {
            final selected = category == selectedCategory;
            return SizedBox(
              width: (constraints.maxWidth - 10) / 2,
              child: Semantics(
                button: true,
                selected: selected,
                label: category.label,
                child: ExcludeSemantics(
                  child: Container(
                    decoration: CreateSupportTicketSelectionStyles.category(
                      selected,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: CreateSupportTicketSelectionStyles.radius,
                        onTap: () => onCategorySelected(category),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 66),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  category.icon,
                                  size: 22,
                                  color:
                                      CreateSupportTicketSelectionStyles.categoryColor(
                                        selected,
                                      ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    category.label,
                                    style:
                                        CreateSupportTicketSelectionStyles.categoryLabel(
                                          selected,
                                        ),
                                  ),
                                ),
                                if (selected) ...[
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}
