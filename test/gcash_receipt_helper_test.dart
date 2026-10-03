import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

void main() {
  group('GcashReceiptHelper', () {
    test('validateReceiptImage returns error when file name is blank', () {
      final error = GcashReceiptHelper.validateReceiptImage(
        fileName: '   ',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      expect(error, 'Upload a GCash receipt image.');
    });

    test('validateReceiptImage rejects blocked extensions', () {
      final error = GcashReceiptHelper.validateReceiptImage(
        fileName: 'receipt.exe',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      expect(error, 'Choose a safe JPG, PNG, or WEBP image.');
    });

    test('validateReceiptImage rejects unsafe characters', () {
      final error = GcashReceiptHelper.validateReceiptImage(
        fileName: 'receipt<bad>.png',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      expect(error, 'Choose a safe JPG, PNG, or WEBP image.');
    });

    test('validateReceiptImage rejects unsupported extension', () {
      final error = GcashReceiptHelper.validateReceiptImage(
        fileName: 'receipt.pdf',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      expect(error, 'Only JPG, PNG, or WEBP receipt images are allowed.');
    });

    test('validateReceiptImage rejects empty bytes', () {
      final error = GcashReceiptHelper.validateReceiptImage(
        fileName: 'receipt.jpg',
        bytes: Uint8List(0),
      );
      expect(error, 'Receipt image file is empty.');
    });

    test('validateReceiptImage rejects file exceeding 5MB', () {
      final largeBytes = Uint8List(5 * 1024 * 1024 + 1);
      final error = GcashReceiptHelper.validateReceiptImage(
        fileName: 'receipt.png',
        bytes: largeBytes,
      );
      expect(error, 'Receipt image must be 5 MB or smaller.');
    });

    test('validateReceiptImage accepts valid PNG image under 5MB', () {
      final validBytes = Uint8List.fromList([137, 80, 78, 71]);
      final error = GcashReceiptHelper.validateReceiptImage(
        fileName: 'receipt.png',
        bytes: validBytes,
      );
      expect(error, isNull);
    });

    test('validateReceiptImage accepts valid JPEG image under 5MB', () {
      final validBytes = Uint8List.fromList([255, 216, 255]);
      final error = GcashReceiptHelper.validateReceiptImage(
        fileName: 'receipt.jpeg',
        bytes: validBytes,
      );
      expect(error, isNull);
    });
  });
}
