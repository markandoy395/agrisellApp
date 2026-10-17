import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class BuyerAvatarRepository {
  const BuyerAvatarRepository(this.client);
  final SupabaseClient client;
  static const bucket = 'buyer-avatars';

  Future<String> save(Uint8List bytes) async {
    final session = client.auth.currentSession;
    if (session == null || session.isExpired || session.user.isAnonymous) {
      throw const AuthException('Sign in before changing your photo.');
    }
    final owner = session.user.id;
    final (_, contentType) = _imageType(bytes);
    void requireOwner() {
      final current = client.auth.currentSession;
      if (current == null ||
          current.isExpired ||
          current.user.isAnonymous ||
          current.user.id != owner) {
        throw const AuthException('Your account changed. Please try again.');
      }
    }

    requireOwner();
    final response = await client.functions.invoke(
      'application-api/avatar',
      body: bytes,
      headers: {'Content-Type': contentType},
    );
    requireOwner();
    final data = response.data;
    if (data is! Map || data['url'] is! String) {
      throw const FormatException('Your photo could not be saved.');
    }
    return data['url'] as String;
  }

  (String, String) _imageType(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw const FormatException('Choose an image under 5 MB.');
    }
    if (bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255) {
      return ('jpg', 'image/jpeg');
    }
    if (bytes.length >= 8 &&
        bytes[0] == 137 &&
        bytes[1] == 80 &&
        bytes[2] == 78 &&
        bytes[3] == 71) {
      return ('png', 'image/png');
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return ('webp', 'image/webp');
    }
    throw const FormatException('Choose a JPG, PNG or WEBP image.');
  }
}
