double? deliveryDouble(Object? value) => switch (value) {
  final num number => number.toDouble(),
  final String text => double.tryParse(text),
  _ => null,
};

int? deliveryInt(Object? value) => switch (value) {
  final int number => number,
  final num number => number.toInt(),
  final String text => int.tryParse(text),
  _ => null,
};

DateTime? deliveryDateTime(Object? value) {
  if (value is DateTime) return value.toLocal();
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

String deliveryString(Object? value, {String fallback = ''}) =>
    value?.toString() ?? fallback;

Map<String, Object?> deliveryJsonMap(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return const <String, Object?>{};
}
