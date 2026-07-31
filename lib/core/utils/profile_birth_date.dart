class ProfileBirthDate {
  const ProfileBirthDate({
    required this.day,
    required this.month,
    required this.year,
  });

  static const months = [
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

  final int? day;
  final int? month;
  final int? year;

  factory ProfileBirthDate.parse(String value) {
    if (value.trim().isEmpty) {
      return const ProfileBirthDate(day: null, month: null, year: null);
    }
    final isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim())
        ? DateTime.tryParse(value.trim())
        : null;
    if (isoDate != null) {
      return ProfileBirthDate._clamped(
        day: isoDate.day,
        month: isoDate.month,
        year: isoDate.year,
      );
    }
    final parts = value.replaceAll(',', '').trim().split(RegExp(r'\s+'));
    final monthName = parts.isNotEmpty ? parts.first : '';
    final month =
        months.indexWhere(
          (item) => item.toLowerCase() == monthName.toLowerCase(),
        ) +
        1;
    return ProfileBirthDate._clamped(
      day: parts.length > 1 ? int.tryParse(parts[1]) : null,
      month: month == 0 ? null : month,
      year: parts.length > 2 ? int.tryParse(parts[2]) : null,
    );
  }

  factory ProfileBirthDate._clamped({
    required int? day,
    required int? month,
    required int? year,
  }) {
    final cleanYear = year == null
        ? null
        : _clamp(year, 1900, DateTime.now().year);
    final cleanMonth = month == null ? null : _clamp(month, 1, 12);
    if (cleanYear == null || cleanMonth == null) {
      return ProfileBirthDate(day: day, month: cleanMonth, year: cleanYear);
    }
    final maxDay = DateTime(cleanYear, cleanMonth + 1, 0).day;
    return ProfileBirthDate(
      day: day == null ? null : _clamp(day, 1, maxDay),
      month: cleanMonth,
      year: cleanYear,
    );
  }

  int get maxDay {
    final selectedMonth = month;
    final selectedYear = year;
    if (selectedMonth == null || selectedYear == null) return 31;
    return DateTime(selectedYear, selectedMonth + 1, 0).day;
  }

  String get formatted {
    if (day == null || month == null || year == null) return '';
    return '${months[month! - 1]} $day, $year';
  }

  ProfileBirthDate copyWith({int? day, int? month, int? year}) {
    return ProfileBirthDate._clamped(
      day: day ?? this.day,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }

  static int _clamp(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
