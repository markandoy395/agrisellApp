part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class GcashReceiptImageException implements Exception {
  const GcashReceiptImageException(this.message);
  final String message;

  @override
  String toString() => 'GcashReceiptImageException: $message';
}

abstract final class GcashReceiptHelper {
  static const int maxFileSizeBytes = 5 * 1024 * 1024;
  static const Set<String> allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};
  static final RegExp _unsafeCharacters = RegExp(r'[\\/:*?"<>|]');
  static final RegExp _blockedExecutableExtensions = RegExp(
    r'\.(apk|bat|cmd|dll|exe|html?|jar|js|msi|php|sh|svg)(\.|$)',
    caseSensitive: false,
  );

  static Future<GcashReceiptImage?> pickDeviceReceiptImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 84,
    );
    if (image == null) return null;
    final bytes = await image.readAsBytes();
    final fileName = imageFileName(image);
    final error = validateReceiptImage(fileName: fileName, bytes: bytes);
    if (error != null) throw GcashReceiptImageException(error);
    return GcashReceiptImage(
      fileName: fileName,
      bytes: bytes,
      proofReference:
          'local-secure://gcash-receipts/${DateTime.now().microsecondsSinceEpoch}',
    );
  }

  static String imageFileName(XFile image) {
    if (image.name.trim().isNotEmpty) return image.name.trim();
    return image.path.split(RegExp(r'[\\/]')).last;
  }

  static String? validateReceiptImage({
    required String fileName,
    required Uint8List bytes,
  }) {
    final cleanFileName = fileName.trim();
    if (cleanFileName.isEmpty) return 'Upload a GCash receipt image.';
    if (_unsafeCharacters.hasMatch(cleanFileName) ||
        _blockedExecutableExtensions.hasMatch(cleanFileName)) {
      return 'Choose a safe JPG, PNG, or WEBP image.';
    }
    final extension = cleanFileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'Only JPG, PNG, or WEBP receipt images are allowed.';
    }
    if (bytes.isEmpty) return 'Receipt image file is empty.';
    if (bytes.length > maxFileSizeBytes) {
      return 'Receipt image must be 5 MB or smaller.';
    }
    return null;
  }
}

Future<GcashReceiptImage?> _pickDeviceGcashReceiptImage() =>
    GcashReceiptHelper.pickDeviceReceiptImage();
