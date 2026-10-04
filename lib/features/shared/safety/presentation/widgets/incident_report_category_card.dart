import 'package:flutter/material.dart';
import '../../domain/safety_incident_category.dart';
import '../styles/incident_report_styles.dart';
import 'incident_report_category_content.dart';

class IncidentReportCategoryCard extends StatelessWidget {
  const IncidentReportCategoryCard({
    required this.category,
    required this.selected,
    required this.onSelected,
    super.key,
  });
  final SafetyIncidentCategory category;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    inMutuallyExclusiveGroup: true,
    label: category.label,
    child: ExcludeSemantics(
      child: Container(
        decoration: IncidentReportStyles.category(selected),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: IncidentReportStyles.radius,
            onTap: onSelected,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: IncidentReportStyles.iconBackground(category),
                    child: Icon(
                      incidentCategoryIcon(category),
                      color: IncidentReportStyles.iconColor(category),
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.label,
                          style: IncidentReportStyles.categoryTitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          incidentCategoryDescription(category),
                          style: IncidentReportStyles.description,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? IncidentReportStyles.green
                        : const Color(0xFFBCC2C0),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
