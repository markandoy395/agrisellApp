/// Formats notification dates in a way that makes recent updates easy to scan.
class NotificationDateLabel {
  const NotificationDateLabel._();

  static String format(DateTime dateTime, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final today = DateTime(reference.year, reference.month, reference.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final time = _time(dateTime);

    if (date == today) return 'Today • $time';
    if (date == yesterday) return 'Yesterday • $time';

    final month = _months[dateTime.month - 1];
    final year = dateTime.year == reference.year ? '' : ', ${dateTime.year}';
    return '$month ${dateTime.day}$year • $time';
  }

  static String _time(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  static const _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
}
