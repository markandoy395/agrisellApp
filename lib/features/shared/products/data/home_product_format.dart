abstract final class HomeProductFormat {
  static Map<String, dynamic> mapValue(Object? value) {
    return value is Map<String, dynamic> ? value : const {};
  }

  static String text(Object? value, {String fallback = ''}) {
    final text = value is String ? value.trim() : value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? optionalText(Object? value) {
    final text = HomeProductFormat.text(value);
    return text.isEmpty ? null : text;
  }

  static double number(Object? value) => switch (value) {
    num number => number.toDouble(),
    String text => double.tryParse(text) ?? 0,
    _ => 0,
  };

  static int? integer(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text),
    _ => null,
  };

  static String displayNumber(Object? value, {String fallback = '0'}) {
    final number = HomeProductFormat.number(value);
    if (value == null) return fallback;
    return number == number.truncateToDouble()
        ? number.toInt().toString()
        : number.toStringAsFixed(2);
  }

  static String displayDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return 'Harvest date unavailable';
    return '${_months[date.month]} ${date.day}, ${date.year}';
  }
}

const _months = <int, String>{
  1: 'January',
  2: 'February',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December',
};
