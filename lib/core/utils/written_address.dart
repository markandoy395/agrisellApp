abstract final class WrittenAddress {
  static final _coordinatePair = RegExp(
    r'^\s*\(?[+-]?\d{1,3}(?:\.\d+)?\s*[,;]\s*'
    r'[+-]?\d{1,3}(?:\.\d+)?\)?\s*$',
  );

  static bool isValid(String value) {
    final address = value.trim();
    return address.isNotEmpty && !_coordinatePair.hasMatch(address);
  }

  static String? valueOrNull(String? value) {
    final address = value?.trim() ?? '';
    return isValid(address) ? address : null;
  }
}
