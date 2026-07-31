part of 'rider_history_screen.dart';

extension _RiderHistoryFilters on _RiderHistoryScreenState {
  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange == null
          ? null
          : DateTimeRange(start: _dateRange!.start, end: _dateRange!.end),
    );
    if (range != null && mounted) {
      _setDateRange(RiderDateRange(start: range.start, end: range.end));
    }
  }
}
