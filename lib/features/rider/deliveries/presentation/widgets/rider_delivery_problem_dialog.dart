import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import '../../domain/rider_delivery_problem.dart';

class RiderDeliveryProblemDraft {
  const RiderDeliveryProblemDraft({
    required this.kind,
    required this.notes,
    this.photoReferences = const [],
  });

  final RiderDeliveryProblemKind kind;
  final String notes;
  final List<String> photoReferences;
}

Future<RiderDeliveryProblemDraft?> showRiderDeliveryProblemDialog(
  BuildContext context, {
  Future<String?> Function()? onCapturePhoto,
}) async {
  var kind = RiderDeliveryProblemKind.productNotReady;
  final notes = TextEditingController();
  final photos = <String>[];
  final result = await showDialog<RiderDeliveryProblemDraft>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Report a delivery problem'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<RiderDeliveryProblemKind>(
                dropdownColor: AppDropdownStyle.menuColor,
                borderRadius: AppDropdownStyle.menuBorderRadius,
                style: AppDropdownStyle.textStyle,
                iconEnabledColor: AppDropdownStyle.iconColor,
                initialValue: kind,
                isExpanded: true,
                items: [
                  for (final item in RiderDeliveryProblemKind.values)
                    DropdownMenuItem(value: item, child: Text(item.label)),
                ],
                onChanged: (value) => setDialogState(() => kind = value!),
                decoration: const InputDecoration(labelText: 'Problem type'),
              ),
              TextField(
                controller: notes,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              if (onCapturePhoto != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(
                    photos.isEmpty
                        ? 'Add protected photo'
                        : '${photos.length} protected photo(s)',
                  ),
                  onTap: () async {
                    final reference = await onCapturePhoto();
                    if (reference != null && context.mounted) {
                      setDialogState(() => photos.add(reference));
                    }
                  },
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
              RiderDeliveryProblemDraft(
                kind: kind,
                notes: notes.text.trim(),
                photoReferences: List.unmodifiable(photos),
              ),
            ),
            child: const Text('Submit report'),
          ),
        ],
      ),
    ),
  );
  notes.dispose();
  return result?.notes.isEmpty ?? true ? null : result;
}
