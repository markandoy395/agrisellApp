part of 'rider_history_screen.dart';

extension _RiderHistoryContent on _RiderHistoryScreenState {
  List<Widget> _content() {
    if (widget.deliveryController != null) return _historyContent();
    return switch (_controller.historyState) {
      RiderAnalyticsLoadState.idle || RiderAnalyticsLoadState.loading => const [
        RiderLoadingStateCard(
          title: 'Loading delivery history',
          message: 'Retrieving closed delivery records.',
        ),
      ],
      RiderAnalyticsLoadState.error => [
        RiderErrorStateCard(
          title: 'History unavailable',
          message: _controller.historyError ?? 'Please try again.',
          retryLabel: 'Retry',
          onRetry: () => unawaited(_load()),
        ),
      ],
      RiderAnalyticsLoadState.ready => _historyContent(),
    };
  }

  List<Widget> _historyContent() {
    final query = _searchController.text;
    final localRecords = widget.deliveryController?.completionHistory
        .map(RiderDeliveryHistoryEntry.fromCompletion)
        .toList();
    final records =
        (localRecords ?? _controller.history)
            .where(
              (record) =>
                  (_filter == null || record.status == _filter) &&
                  (_dateRange == null ||
                      (!record.completedAt.isBefore(_dateRange!.start) &&
                          record.completedAt.isBefore(
                            _dateRange!.end.add(const Duration(days: 1)),
                          ))) &&
                  record.matchesSearch(query),
            )
            .toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    if (records.isEmpty) {
      return [
        RiderEmptyStateCard(
          title: 'No deliveries found',
          message: query.trim().isEmpty && _filter == null
              ? 'Delivery date, locations, product details, fees, status, and ratings will appear here.'
              : 'Try a different search term or delivery status.',
          icon: Icons.history_rounded,
        ),
      ];
    }
    return [
      for (final record in records) ...[
        RiderHistoryEntryCard(
          entry: record,
          onTap: () => Navigator.of(context).push(
            agrisellPageRoute<void>(
              builder: (_) => RiderHistoryDetailsScreen(entry: record),
            ),
          ),
        ),
        const SizedBox(height: RiderHistoryStyles.spacing8),
      ],
    ];
  }
}
