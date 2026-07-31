import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';

class RiderDocumentUploadException implements Exception {
  const RiderDocumentUploadException(this.message);
  final String message;
}

class RiderDocumentUploadService {
  RiderDocumentUploadService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  static const maxBytes = 8 * 1024 * 1024;
  static const _extensions = {'jpg', 'jpeg', 'png', 'webp'};
  final ImagePicker _picker;

  Future<RiderDraftDocument?> pick({
    required RiderDraftDocumentType type,
    required ImageSource source,
  }) async {
    final selected = await _picker.pickImage(source: source, imageQuality: 88);
    if (selected == null) return null;
    final extension = selected.name.split('.').last.toLowerCase();
    if (!_extensions.contains(extension)) {
      throw const RiderDocumentUploadException(
        'Use a JPG, PNG, or WEBP image.',
      );
    }
    final length = await selected.length();
    if (length == 0 || length > maxBytes) {
      throw const RiderDocumentUploadException(
        'Each document must be under 8 MB.',
      );
    }
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        '${type.name}_${DateTime.now().microsecondsSinceEpoch}.$extension';
    final saved = await File(selected.path).copy('${directory.path}/$fileName');
    return RiderDraftDocument(path: saved.path, fileName: fileName);
  }

  Future<void> remove(RiderDraftDocument? document) async {
    if (document == null) return;
    final file = File(document.path);
    if (await file.exists()) await file.delete();
  }
}
