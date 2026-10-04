import 'package:flutter/material.dart';
import '../../domain/safety_incident_category.dart';
import '../styles/incident_report_styles.dart';
import 'incident_report_category_card.dart';
import 'incident_report_dialog.dart';

class IncidentReportSheet extends StatefulWidget {
  const IncidentReportSheet({required this.categories, super.key});
  final List<SafetyIncidentCategory> categories;
  @override
  State<IncidentReportSheet> createState() => _IncidentReportSheetState();
}

class _IncidentReportSheetState extends State<IncidentReportSheet> {
  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  late SafetyIncidentCategory _selected;
  @override
  void initState() {
    super.initState();
    _selected = widget.categories.first;
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      IncidentReportInput(
        category: _selected,
        description: _description.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Safety Incident',
            style: IncidentReportStyles.title,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Incident Category',
                      style: IncidentReportStyles.sectionTitle,
                    ),
                    const SizedBox(height: 10),
                    for (final category in widget.categories) ...[
                      IncidentReportCategoryCard(
                        category: category,
                        selected: category == _selected,
                        onSelected: () => setState(() => _selected = category),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 10),
                    const Text(
                      'Describe the Incident',
                      style: IncidentReportStyles.sectionTitle,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _description,
                      minLines: 3,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      style: IncidentReportStyles.inputText,
                      decoration: IncidentReportStyles.input,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please describe the incident.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: IncidentReportStyles.cancelButton,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _submit,
                  style: IncidentReportStyles.submitButton,
                  child: const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
