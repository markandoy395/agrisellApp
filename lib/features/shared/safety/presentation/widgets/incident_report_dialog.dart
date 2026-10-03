import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import '../styles/app_safety_sheet_styles.dart';
import '../utils/app_safety_coordinator.dart';

class IncidentReportInput {
  const IncidentReportInput({
    required this.category,
    required this.description,
  });

  final SafetyIncidentCategory category;
  final String description;
}

Future<IncidentReportInput?> showIncidentReportDialog({
  required BuildContext context,
  required String role,
  int? orderId,
  int? deliveryId,
}) async {
  final categories = AppSafetyCoordinator.categoriesForRole(role);
  var selectedCategory = categories.first;
  final controller = TextEditingController();

  return showDialog<IncidentReportInput>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('Report Safety Incident'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Incident Category',
                style: AppSafetySheetStyles.dialogFieldLabelStyle,
              ),
              AppSafetySheetStyles.spacingDialogFields,
              DropdownButtonFormField<SafetyIncidentCategory>(
                initialValue: selectedCategory,
                isExpanded: true,
                decoration: AppSafetySheetStyles.dropdownDecoration,
                items: categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat.label,
                          style: AppSafetySheetStyles.dropdownItemStyle,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (cat) {
                  if (cat != null) {
                    setDialogState(() => selectedCategory = cat);
                  }
                },
              ),
              AppSafetySheetStyles.spacingDialogSections,
              const Text(
                'Describe the Incident',
                style: AppSafetySheetStyles.dialogFieldLabelStyle,
              ),
              AppSafetySheetStyles.spacingDialogFields,
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
                decoration: AppSafetySheetStyles.reportInputDecoration,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: AppSafetySheetStyles.submitReportButtonStyle,
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(ctx).pop(
                IncidentReportInput(
                  category: selectedCategory,
                  description: text,
                ),
              );
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    ),
  );
}
