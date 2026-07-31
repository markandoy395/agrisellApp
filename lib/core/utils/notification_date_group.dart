enum NotificationDateGroup {
  today('Today'),
  yesterday('Yesterday'),
  earlier('Earlier');

  const NotificationDateGroup(this.label);

  final String label;

  static NotificationDateGroup from(DateTime value, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final date = DateTime(value.year, value.month, value.day);
    final today = DateTime(reference.year, reference.month, reference.day);
    if (date == today) return NotificationDateGroup.today;
    if (date == today.subtract(const Duration(days: 1))) {
      return NotificationDateGroup.yesterday;
    }
    return NotificationDateGroup.earlier;
  }
}
