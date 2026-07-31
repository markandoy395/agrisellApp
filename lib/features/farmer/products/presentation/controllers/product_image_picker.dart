import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

typedef ProductImagePicker = Future<Uint8List?> Function();

Future<Uint8List?> pickDeviceProductImage(ImagePicker picker) async {
  final image = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1280,
    maxHeight: 1280,
    imageQuality: 82,
  );
  return image?.readAsBytes();
}
