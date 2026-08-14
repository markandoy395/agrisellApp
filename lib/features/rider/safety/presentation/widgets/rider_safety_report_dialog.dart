import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/features/rider/safety/domain/rider_safety_report.dart';

class RiderSafetyReportDraft {
  const RiderSafetyReportDraft({
    required this.category,
    required this.description,
    required this.actions,
    this.attachments = const [],
  });

  final RiderSafetyCategory category;
  final String description;
  final Set<RiderSafetyResponseAction> actions;
  final List<String> attachments;
}

Future<RiderSafetyReportDraft?> showRiderSafetyReportDialog(
  BuildContext context, {
  Future<String?> Function()? onCapturePhoto,
}) async {
  var category = RiderSafetyCategory.unsafePickup;
  final description = TextEditingController();
  final selected = <RiderSafetyResponseAction>{
    RiderSafetyResponseAction.contactSupport,
    RiderSafetyResponseAction.shareLocationWithSupport,
  };
  final attachments = <String>[];
  final result = await showDialog<RiderSafetyReportDraft>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Report a safety concern'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<RiderSafetyCategory>(
                dropdownColor: AppDropdownStyle.menuColor,
                borderRadius: AppDropdownStyle.menuBorderRadius,
                style: AppDropdownStyle.textStyle,
                iconEnabledColor: AppDropdownStyle.iconColor,
                initialValue: category,
                items: [
                  for (final item in RiderSafetyCategory.values)
                    DropdownMenuItem(value: item, child: Text(_label(item))),
                ],
                onChanged: (value) => setDialogState(() => category = value!),
                decoration: const InputDecoration(labelText: 'Safety category'),
              ),
              TextField(
                controller: description,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Describe the concern',
                ),
              ),
              if (onCapturePhoto != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(
                    attachments.isEmpty
                        ? 'Add protected photo'
                        : '${attachments.length} protected photo(s)',
                  ),
                  onTap: () async {
                    final reference = await onCapturePhoto();
                    if (reference != null && context.mounted) {
                      setDialogState(() => attachments.add(reference));
                    }
                  },
                ),
              for (final action in RiderSafetyResponseAction.values)
                CheckboxListTile(
                  value: selected.contains(action),
                  contentPadding: EdgeInsets.zero,
                  title: Text(_actionLabel(action)),
                  onChanged: (checked) => setDialogState(() {
                    if (checked ?? false) {
                      selected.add(action);
                    } else {
                      selected.remove(action);
                    }
                  }),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              RiderSafetyReportDraft(
                category: category,
                description: description.text.trim(),
                actions: Set.unmodifiable(selected),
                attachments: List.unmodifiable(attachments),
              ),
            ),
            child: const Text('Send to support'),
          ),
        ],
      ),
    ),
  );
  description.dispose();
  return result?.description.isEmpty ?? true ? null : result;
}

String _label(RiderSafetyCategory value) => value.name
    .replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match[1]} ${match[2]}',
    )
    .replaceFirstMapped(RegExp(r'^.'), (match) => match[0]!.toUpperCase());

String _actionLabel(RiderSafetyResponseAction value) => switch (value) {
  RiderSafetyResponseAction.contactSupport => 'Contact support',
  RiderSafetyResponseAction.shareLocationWithSupport =>
    'Share location with support',
  RiderSafetyResponseAction.requestReassignment => 'Request reassignment',
  RiderSafetyResponseAction.requestCancellation => 'Request cancellation',
  RiderSafetyResponseAction.continueWhenSafe => 'Continue when safe',
};
