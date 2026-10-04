import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import '../styles/create_support_ticket_styles.dart';
import '../styles/create_support_ticket_selection_styles.dart';

class CreateSupportTicketPriorityPicker extends StatelessWidget {
  const CreateSupportTicketPriorityPicker({
    required this.selectedPriority,
    required this.onPrioritySelected,
    super.key,
  });
  final SupportTicketPriority selectedPriority;
  final ValueChanged<SupportTicketPriority> onPrioritySelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Priority', style: CreateSupportTicketStyles.sectionHeading),
      const SizedBox(height: 4),
      const Text(
        'Select the priority level for your request.',
        style: CreateSupportTicketStyles.description,
      ),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns =
              constraints.maxWidth < 350 ||
                  MediaQuery.textScalerOf(context).scale(14) > 18
              ? 2
              : 4;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SupportTicketPriority.values.map((priority) {
              final selected = priority == selectedPriority;
              return SizedBox(
                width: (constraints.maxWidth - 8 * (columns - 1)) / columns,
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: priority.label,
                  child: ExcludeSemantics(
                    child: Container(
                      decoration: CreateSupportTicketSelectionStyles.priority(
                        selected,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              CreateSupportTicketSelectionStyles.radius,
                          onTap: () => onPrioritySelected(priority),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (selected) ...[
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color:
                                        CreateSupportTicketStyles.primaryGreen,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: Text(
                                    priority.label,
                                    style:
                                        CreateSupportTicketSelectionStyles.priorityLabel(
                                          selected,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    ],
  );
}
