abstract final class FarmerCommodityFormat {
  static String databaseMessage(Object? errorCode, String detail) {
    return switch (errorCode) {
      '42501' => 'You are not authorized to save this product.',
      '23503' => 'The selected farm or category is no longer available.',
      _ when detail.trim().isNotEmpty => detail.trim(),
      _ => 'The product could not be saved. Please try again.',
    };
  }

  static String databaseDate(String formattedDate) {
    final match = RegExp(
      r'^(\w+) (\d{1,2}), (\d{4})$',
    ).firstMatch(formattedDate);
    final month = _monthNumbers[match?.group(1)];
    final day = int.tryParse(match?.group(2) ?? '');
    final year = int.tryParse(match?.group(3) ?? '');
    if (month == null || day == null || year == null || day < 1 || day > 31) {
      throw const FarmerCommodityException('Select a valid harvest date.');
    }
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      throw const FarmerCommodityException('Select a valid harvest date.');
    }
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String displayDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return value;
    final monthNumber = int.tryParse(parts[1]);
    String? month;
    for (final entry in _monthNumbers.entries) {
      if (entry.value == monthNumber) month = entry.key;
    }
    if (month == null) return value;
    return '$month ${int.tryParse(parts[2]) ?? parts[2]}, ${parts[0]}';
  }

  static int integer(Object? value) =>
      value is int ? value : int.parse(value.toString());

  static int? optionalInteger(Object? value) =>
      value is int ? value : int.tryParse(value?.toString().trim() ?? '');

  static double number(String value) =>
      double.parse(RegExp(r'[\d.]+').firstMatch(value)?.group(0) ?? '');

  static String text(Object? value, {String fallback = ''}) =>
      optionalText(value) ?? fallback;

  static String? optionalText(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static String displayNumber(Object? value) {
    final number = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    return number.toStringAsFixed(number.truncateToDouble() == number ? 0 : 2);
  }
}

class FarmerCommodityException implements Exception {
  const FarmerCommodityException(this.message);

  final String message;
}

class FarmRequiredException extends FarmerCommodityException {
  const FarmRequiredException()
    : super('Set up a farm before adding products.');
}

const _monthNumbers = <String, int>{
  'January': 1,
  'February': 2,
  'March': 3,
  'April': 4,
  'May': 5,
  'June': 6,
  'July': 7,
  'August': 8,
  'September': 9,
  'October': 10,
  'November': 11,
  'December': 12,
};
