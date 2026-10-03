const _monthNames = [
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

String formatPayoutDate(DateTime? dateTime) {
  if (dateTime == null) return 'Pending';
  final month = _monthNames[dateTime.month - 1];
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$month $day, ${dateTime.year}';
}

String formatPayoutDateTime(DateTime? dateTime) {
  if (dateTime == null) return 'Pending';
  final hour = dateTime.hour > 12
      ? dateTime.hour - 12
      : (dateTime.hour == 0 ? 12 : dateTime.hour);
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '${formatPayoutDate(dateTime)} · $hour:$minute $period';
}
