class OrderAcceptancePolicy {
  const OrderAcceptancePolicy._();

  static const openingHour = 6;
  static const closingHour = 20;
  static const acceptanceHours = 4;

  static DateTime deadlineFor(DateTime placedAt) {
    var start = placedAt;
    final opening = _atHour(start, openingHour);
    final closing = _atHour(start, closingHour);
    if (start.isBefore(opening)) {
      start = opening;
    } else if (!start.isBefore(closing)) {
      start = _atHour(start.add(const Duration(days: 1)), openingHour);
    }

    final deadline = start.add(const Duration(hours: acceptanceHours));
    final activeClosing = _atHour(start, closingHour);
    if (!deadline.isAfter(activeClosing)) return deadline;
    final overflow = deadline.difference(activeClosing);
    return _atHour(
      start.add(const Duration(days: 1)),
      openingHour,
    ).add(overflow);
  }

  static DateTime _atHour(DateTime value, int hour) {
    if (value.isUtc) {
      return DateTime.utc(value.year, value.month, value.day, hour);
    }
    return DateTime(value.year, value.month, value.day, hour);
  }
}
