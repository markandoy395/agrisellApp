import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';

class RiderSignUpDocumentTile extends StatelessWidget {
  const RiderSignUpDocumentTile({
    required this.type,
    required this.document,
    required this.required,
    required this.onPick,
    required this.onRemove,
    super.key,
  });

  final RiderDraftDocumentType type;
  final RiderDraftDocument? document;
  final bool required;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final item = document;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AgrisellColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgrisellColors.borderLine),
      ),
      child: Row(
        children: [
          _Preview(document: item),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${type.label}${required ? '' : ' (optional)'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item?.fileName ?? 'JPG, PNG, or WEBP up to 8 MB',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AgrisellColors.mutedText,
                  ),
                ),
                if (item != null) ...[
                  const SizedBox(height: 5),
                  LinearProgressIndicator(value: item.progress, minHeight: 4),
                  const SizedBox(height: 3),
                  Text(item.status.label, style: const TextStyle(fontSize: 12)),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: item == null
                ? 'Upload ${type.label}'
                : 'Replace ${type.label}',
            onPressed: onPick,
            icon: const Icon(Icons.upload_file_rounded),
          ),
          if (item != null)
            IconButton(
              tooltip: 'Remove ${type.label}',
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded),
            ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.document});
  final RiderDraftDocument? document;

  @override
  Widget build(BuildContext context) {
    final item = document;
    if (item == null) {
      return const SizedBox.square(
        dimension: 46,
        child: Icon(
          Icons.description_outlined,
          color: AgrisellColors.authGreen,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(item.path),
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.square(
          dimension: 46,
          child: Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}

Future<ImageSource?> showRiderDocumentSourceSheet(BuildContext context) =>
    showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text(
                'Take a clear photo',
                style: TextStyle(fontSize: 13),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(fontSize: 13),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
