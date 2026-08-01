import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_history_widgets.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_history_filters.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_history_details_screen.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';

part 'rider_history_filters.dart';

class RiderHistoryScreen extends StatefulWidget {
  const RiderHistoryScreen({
    this.riderId = '',
    this.controller,
    this.deliveryController,
    super.key,
  });

  final String riderId;
  final RiderAnalyticsController? controller;
  final RiderDeliveryController? deliveryController;

  @override
  State<RiderHistoryScreen> createState() => _RiderHistoryScreenState();
}

class _RiderHistoryScreenState extends State<RiderHistoryScreen> {
  late final RiderAnalyticsController _controller;
  late final bool _ownsController;
  final _searchController = TextEditingController();
  RiderHistoryStatus? _filter;
  RiderDateRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? RiderAnalyticsController();
    if (widget.deliveryController == null) unawaited(_load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    body: Column(
      children: [
        RiderPageHeader(
          title: 'Delivery history',
          subtitle: 'Completed, cancelled, and failed deliveries',
          action: IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              color: AgrisellColors.surface,
            ),
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _controller,
              ?widget.deliveryController,
            ]),
            builder: (context, _) => ListView(
              padding: const EdgeInsets.all(14),
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText:
                        'Search order, product, participant, location, or payment',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AgrisellColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                RiderHistoryFilterChips(
                  selected: _filter,
                  onChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range_outlined, size: 18),
                    label: Text(
                      _dateRange == null ? 'Filter by date' : 'Date selected',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._content(),
              ],
            ),
          ),
        ),
      ],
    ),
  );

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
        const SizedBox(height: 8),
      ],
    ];
  }

  Future<void> _load() => _controller.loadHistory(riderId: widget.riderId);

  void _setDateRange(RiderDateRange value) =>
      setState(() => _dateRange = value);
}
