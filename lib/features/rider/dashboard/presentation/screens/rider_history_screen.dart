import 'package:agresell_app/features/rider/presentation/widgets/rider_safe_scaffold.dart';
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
import 'package:agresell_app/features/rider/reporting/rider_financial_exporter.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_history_details_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_history_styles.dart';
import 'package:agresell_app/features/shared/reporting/widgets/export_report_sheet.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';

part 'rider_history_filters.dart';
part 'rider_history_content.dart';

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

  void _exportDeliveriesCsv() {
    final report = RiderFinancialExporter.buildDeliveryHistoryReport(
      deliveries: _controller.history,
    );
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    ExportReportSheet.show(
      context,
      title: 'Rider Delivery Manifest',
      fileName: 'rider_deliveries_$dateStr.csv',
      headers: report.headers,
      rows: report.rows,
      totalAmountLabel: '₱${report.totalAmount.toStringAsFixed(2)}',
    );
  }

  @override
  Widget build(BuildContext context) => RiderSafeScaffold(
    backgroundColor: AgrisellColors.homeBackground,
    body: Column(
      children: [
        RiderPageHeader(
          title: 'Delivery history',
          subtitle: 'Completed, cancelled, and failed deliveries',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Export CSV',
                onPressed: _exportDeliveriesCsv,
                icon: const Icon(
                  Icons.file_download_outlined,
                  color: AgrisellColors.surface,
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AgrisellColors.surface,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _controller,
              ?widget.deliveryController,
            ]),
            builder: (context, _) => ListView(
              padding: RiderHistoryStyles.listPadding,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: RiderHistoryStyles.searchInputDecoration,
                ),
                const SizedBox(height: RiderHistoryStyles.spacing12),
                RiderHistoryFilterChips(
                  selected: _filter,
                  onChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: RiderHistoryStyles.spacing8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(
                      Icons.date_range_outlined,
                      size: RiderHistoryStyles.dateFilterIconSize,
                    ),
                    label: Text(
                      _dateRange == null ? 'Filter by date' : 'Date selected',
                    ),
                  ),
                ),
                const SizedBox(height: RiderHistoryStyles.spacing16),
                ..._content(),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _load() => _controller.loadHistory(riderId: widget.riderId);

  void _setDateRange(RiderDateRange value) =>
      setState(() => _dateRange = value);
}
