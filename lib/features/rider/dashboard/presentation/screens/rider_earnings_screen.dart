import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_cash_out_dialog.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_earnings_history.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_earnings_widgets.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_withdrawal_methods_sheet.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';
import 'package:agresell_app/features/rider/reporting/rider_financial_exporter.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_ratings_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_history_details_screen.dart';
import 'package:agresell_app/features/shared/reporting/widgets/export_report_sheet.dart';

class RiderEarningsScreen extends StatefulWidget {
  const RiderEarningsScreen({this.riderId = '', this.controller, super.key});
  final String riderId;
  final RiderAnalyticsController? controller;
  @override
  State<RiderEarningsScreen> createState() => _RiderEarningsScreenState();
}

class _RiderEarningsScreenState extends State<RiderEarningsScreen> {
  late final RiderAnalyticsController _controller;
  late final bool _ownsController;
  var _period = RiderAnalyticsPeriod.today;
  RiderDateRange? _customRange;
  RiderDateRange get _dateRange =>
      _customRange ?? RiderDateRange.forPeriod(_period, DateTime.now());
  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? RiderAnalyticsController();
    unawaited(_load());
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _exportEarningsCsv() {
    final report = RiderFinancialExporter.buildEarningsReport(
      earnings: _controller.earnings.entries,
      dateRange: _dateRange,
      summary: _controller.earnings.summary,
    );
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    ExportReportSheet.show(
      context,
      title: 'Rider Earnings Statement',
      fileName: 'rider_earnings_$dateStr.csv',
      headers: report.headers,
      rows: report.rows,
      totalAmountLabel: formatRiderCurrency(report.totalAmount),
      dateRangeLabel: report.dateRangeLabel,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    body: Column(
      children: [
        RiderPageHeader(
          title: 'Earnings',
          subtitle: formatRiderDateRange(_dateRange),
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Export CSV',
                onPressed: _exportEarningsCsv,
                icon: const Icon(
                  Icons.file_download_outlined,
                  color: AgrisellColors.surface,
                ),
              ),
              IconButton(
                tooltip: 'Withdrawal methods',
                onPressed: _openWithdrawalMethods,
                icon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AgrisellColors.surface,
                ),
              ),
              IconButton(
                tooltip: 'View ratings',
                onPressed: _openRatings,
                icon: const Icon(
                  Icons.star_outline_rounded,
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
            animation: _controller,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.all(14),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final period in RiderAnalyticsPeriod.values)
                      ChoiceChip(
                        label: Text(period.label),
                        selected: _period == period,
                        onSelected: (_) => _selectPeriod(period),
                        labelStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                ..._content(),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  List<Widget> _content() {
    return switch (_controller.earningsState) {
      RiderAnalyticsLoadState.idle || RiderAnalyticsLoadState.loading => const [
        RiderLoadingStateCard(
          title: 'Loading earnings',
          message: 'Retrieving rider earnings and payout details.',
        ),
      ],
      RiderAnalyticsLoadState.error => [
        RiderErrorStateCard(
          title: 'Earnings unavailable',
          message: _controller.earningsError ?? 'Please try again.',
          retryLabel: 'Retry',
          onRetry: () => unawaited(_load()),
        ),
      ],
      RiderAnalyticsLoadState.ready when !_controller.earnings.hasData => [
        RiderEarningsSummaryCard(
          summary: _controller.earnings.summary,
          onCashOut: _openCashOut,
          onManageMethods: _openWithdrawalMethods,
        ),
        const SizedBox(height: 12),
        const RiderEmptyStateCard(
          title: 'No earnings yet',
          message:
              'Completed delivery fees, incentives, bonuses, deductions, and payout status will appear here.',
          icon: Icons.account_balance_wallet_outlined,
        ),
      ],
      RiderAnalyticsLoadState.ready => [
        RiderEarningsSummaryCard(
          summary: _controller.earnings.summary,
          onCashOut: _openCashOut,
          onManageMethods: _openWithdrawalMethods,
        ),
        const SizedBox(height: 12),
        RiderEarningsBreakdownCard(summary: _controller.earnings.summary),
        if (_controller.earnings.entries.isNotEmpty) ...[
          const SizedBox(height: 14),
          RiderEarningsHistory(
            entries: _controller.earnings.entries,
            onOpenDelivery: _openDelivery,
          ),
        ],
      ],
    };
  }

  Future<void> _selectPeriod(RiderAnalyticsPeriod period) async {
    if (period == RiderAnalyticsPeriod.custom) {
      final today = DateTime.now();
      final selected = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(today.year, today.month, today.day),
        initialDateRange: DateTimeRange(
          start: _dateRange.start,
          end: _dateRange.end,
        ),
      );
      if (selected == null || !mounted) return;
      setState(() {
        _period = period;
        _customRange = RiderDateRange.fromDates(selected.start, selected.end);
      });
    } else {
      setState(() {
        _period = period;
        _customRange = null;
      });
    }
    await _load();
  }

  Future<void> _load() =>
      _controller.loadEarnings(riderId: widget.riderId, dateRange: _dateRange);

  void _openRatings() {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => RiderRatingsScreen(
          riderId: widget.riderId,
          controller: _controller,
        ),
      ),
    );
  }

  void _openWithdrawalMethods() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AgrisellColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RiderWithdrawalMethodsSheet(
        riderId: widget.riderId,
        controller: _controller,
      ),
    );
  }

  Future<void> _openCashOut() async {
    await _controller.loadWithdrawalMethods(riderId: widget.riderId);
    if (!mounted) return;

    if (_controller.withdrawalMethods.isEmpty) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(
          content: Text('Please add a withdrawal method first before cashing out.'),
        ),
      );
      _openWithdrawalMethods();
      return;
    }

    final result = await showDialog<RiderWithdrawalRequest>(
      context: context,
      builder: (_) => RiderCashOutDialog(
        riderId: widget.riderId,
        controller: _controller,
        availableEarnings: _controller.earnings.summary.netEarnings > 0
            ? _controller.earnings.summary.netEarnings
            : 0,
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            'Cash-out request for ${formatRiderCurrency(result.amount)} submitted successfully.',
          ),
          backgroundColor: AgrisellColors.authGreen,
        ),
      );
      await _load();
    }
  }

  Future<void> _openDelivery(String deliveryId) async {
    await _controller.loadHistory(riderId: widget.riderId);
    if (!mounted) return;
    final matches = _controller.history.where(
      (entry) => entry.id == deliveryId,
    );
    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('Delivery history is unavailable.')),
      );
      return;
    }
    await Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => RiderHistoryDetailsScreen(entry: matches.first),
      ),
    );
  }
}
