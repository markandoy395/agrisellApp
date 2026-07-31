import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';

String formatRiderCurrency(double value) => '\u20B1${value.toStringAsFixed(2)}';

String formatRiderDate(DateTime value) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

String formatRiderDateTime(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '${formatRiderDate(value)} · $hour:$minute $suffix';
}

String formatRiderDateRange(RiderDateRange range) {
  if (range.start.year == range.end.year &&
      range.start.month == range.end.month &&
      range.start.day == range.end.day) {
    return formatRiderDate(range.start);
  }
  return '${formatRiderDate(range.start)} – ${formatRiderDate(range.end)}';
}
