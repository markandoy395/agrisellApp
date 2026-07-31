import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PasswordHash {
  const PasswordHash({required this.value, required this.salt});

  final String value;
  final String salt;
}

class PasswordHasher {
  const PasswordHasher();

  static const int _iterations = 210000;
  static const int _keyLength = 32;

  PasswordHash hash(String password) {
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    return PasswordHash(
      value: base64UrlEncode(_derive(password, salt)),
      salt: base64UrlEncode(salt),
    );
  }

  bool verify({
    required String password,
    required String hash,
    required String salt,
  }) {
    final expected = _decodeBase64Url(hash);
    final actual = _derive(password, _decodeBase64Url(salt));
    return _constantTimeEquals(expected, actual);
  }

  List<int> _derive(String password, List<int> salt) {
    final passwordBytes = utf8.encode(password);
    final hmac = Hmac(sha256, passwordBytes);
    final firstBlock = <int>[...salt, 0, 0, 0, 1];
    var iteration = hmac.convert(firstBlock).bytes;
    final derived = List<int>.from(iteration);
    for (var count = 1; count < _iterations; count++) {
      iteration = hmac.convert(iteration).bytes;
      for (var index = 0; index < _keyLength; index++) {
        derived[index] ^= iteration[index];
      }
    }
    return derived;
  }

  bool _constantTimeEquals(List<int> expected, List<int> actual) {
    if (expected.length != actual.length) return false;
    var difference = 0;
    for (var index = 0; index < expected.length; index++) {
      difference |= expected[index] ^ actual[index];
    }
    return difference == 0;
  }

  List<int> _decodeBase64Url(String value) {
    final padding = (4 - value.length % 4) % 4;
    return base64Url.decode(value.padRight(value.length + padding, '='));
  }
}
