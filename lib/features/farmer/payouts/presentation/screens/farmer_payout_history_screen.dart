import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/payouts/data/farmer_payout_repository.dart';
import 'package:agresell_app/features/farmer/payouts/data/supabase_farmer_payout_repository.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';
import 'package:agresell_app/features/farmer/payouts/presentation/widgets/farmer_cash_out_dialog.dart';
import 'package:agresell_app/features/farmer/reporting/farmer_financial_exporter.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';
import 'package:agresell_app/features/shared/reporting/widgets/export_report_sheet.dart';

enum FarmerPayoutFilter { all, paid, pending, failed }

class FarmerPayoutHistoryScreen extends StatefulWidget {
  const FarmerPayoutHistoryScreen({
    this.repository,
    this.initialFilter = FarmerPayoutFilter.all,
    super.key,
  });

  final FarmerPayoutRepository? repository;
  final FarmerPayoutFilter initialFilter;

  @override
  State<FarmerPayoutHistoryScreen> createState() =>
      _FarmerPayoutHistoryScreenState();
}

class _FarmerPayoutHistoryScreenState extends State<FarmerPayoutHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final FarmerPayoutRepository _repository;
  late final TabController _tabController;
  var _payouts = <FarmerPayout>[];
  var _cashOutRequests = <FarmerCashOutRequest>[];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ??
        (AgrisellSupabase.isInitialized
            ? SupabaseFarmerPayoutRepository(AgrisellSupabase.client)
            : InMemoryFarmerPayoutRepository());
    _tabController = TabController(
      length: FarmerPayoutFilter.values.length,
      initialIndex: widget.initialFilter.index,
      vsync: this,
    );
    _loadPayouts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPayouts() async {
    setState(() => _isLoading = true);
    final results = await _repository.loadPayouts();
    final requests = await _repository.loadCashOutRequests();
    if (!mounted) return;
    setState(() {
      _payouts = results;
      _cashOutRequests = requests;
      _isLoading = false;
    });
  }

  List<FarmerPayout> _filterPayouts(FarmerPayoutFilter filter) {
    return switch (filter) {
      FarmerPayoutFilter.all => _payouts,
      FarmerPayoutFilter.paid =>
        _payouts.where((p) => p.isPaid).toList(growable: false),
      FarmerPayoutFilter.pending => _payouts
          .where((p) => p.isApproved || p.status == FarmerPayoutStatus.pending)
          .toList(growable: false),
      FarmerPayoutFilter.failed =>
        _payouts.where((p) => p.isFailed).toList(growable: false),
    };
  }

  List<FarmerCashOutRequest> _filterCashOutRequests(FarmerPayoutFilter filter) {
    return switch (filter) {
      FarmerPayoutFilter.all => _cashOutRequests,
      FarmerPayoutFilter.paid =>
        _cashOutRequests.where((r) => r.isPaid).toList(growable: false),
      FarmerPayoutFilter.pending => _cashOutRequests
          .where((r) => r.isPending || r.isApproved)
          .toList(growable: false),
      FarmerPayoutFilter.failed =>
        _cashOutRequests.where((r) => r.isRejected).toList(growable: false),
    };
  }

  Future<void> _openCashOutDialog() async {
    final result = await showModalBottomSheet<FarmerCashOutRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FarmerCashOutDialog(
        onSubmit: _repository.submitCashOutRequest,
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            'Cash-out request for ${formatBasketPeso(result.amount)} submitted successfully.',
          ),
          backgroundColor: AgrisellColors.authGreen,
        ),
      );
      await _loadPayouts();
    }
  }

  void _exportPayoutsCsv() {
    final report = FarmerFinancialExporter.buildPayoutsReport(
      payouts: _payouts,
      cashOutRequests: _cashOutRequests,
    );
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    ExportReportSheet.show(
      context,
      title: 'Farmer Payouts Statement',
      fileName: 'farmer_payouts_$dateStr.csv',
      headers: report.headers,
      rows: report.rows,
      totalAmountLabel: formatBasketPeso(report.totalAmount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = FarmerPayoutSummary.fromPayouts(_payouts);

    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(
        title: const Text(
          'Payout & Disbursement History',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AgrisellColors.authGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _exportPayoutsCsv,
          ),
          TextButton.icon(
            onPressed: _openCashOutDialog,
            icon: const Icon(Icons.payments_rounded, size: 16, color: Colors.white),
            label: const Text(
              'Cash Out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadPayouts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AgrisellColors.authGreen,
              ),
            )
          : Column(
              children: [
                _PayoutMetricsHeader(
                  summary: summary,
                  onCashOut: _openCashOutDialog,
                ),
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AgrisellColors.authGreen,
                    indicatorWeight: 3,
                    labelColor: AgrisellColors.authGreen,
                    unselectedLabelColor: AgrisellColors.mutedText,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Paid'),
                      Tab(text: 'Pending'),
                      Tab(text: 'Failed'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      for (final filter in FarmerPayoutFilter.values)
                        _PayoutListView(
                          payouts: _filterPayouts(filter),
                          cashOutRequests: _filterCashOutRequests(filter),
                          filter: filter,
                          onRefresh: _loadPayouts,
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PayoutMetricsHeader extends StatelessWidget {
  const _PayoutMetricsHeader({
    required this.summary,
    required this.onCashOut,
  });

  final FarmerPayoutSummary summary;
  final VoidCallback onCashOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Disbursed',
                  amount: formatBasketPeso(summary.totalPaidOut),
                  countText: '${summary.paidCount} completed',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: AgrisellColors.statusGreenText,
                  backgroundColor: AgrisellColors.statusGreenBackground,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: 'Pending Payouts',
                  amount: formatBasketPeso(summary.pendingPayouts),
                  countText: '${summary.pendingCount} in transit',
                  icon: Icons.hourglass_top_rounded,
                  iconColor: AgrisellColors.statusOrangeText,
                  backgroundColor: AgrisellColors.statusOrangeBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCashOut,
              icon: const Icon(Icons.payments_rounded, size: 18),
              label: const Text(
                'Request Payout / Cash Out',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AgrisellColors.authGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.amount,
    required this.countText,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final String title;
  final String amount;
  final String countText;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            countText,
            style: const TextStyle(
              fontSize: 12,
              color: AgrisellColors.mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutListView extends StatelessWidget {
  const _PayoutListView({
    required this.payouts,
    required this.cashOutRequests,
    required this.filter,
    required this.onRefresh,
  });

  final List<FarmerPayout> payouts;
  final List<FarmerCashOutRequest> cashOutRequests;
  final FarmerPayoutFilter filter;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final totalItems = payouts.length + cashOutRequests.length;

    if (totalItems == 0) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AgrisellColors.searchBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.payments_outlined,
                      size: 30,
                      color: AgrisellColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    filter == FarmerPayoutFilter.paid
                        ? 'No paid disbursements yet'
                        : (filter == FarmerPayoutFilter.pending
                            ? 'No pending payouts'
                            : (filter == FarmerPayoutFilter.failed
                                ? 'No failed payouts'
                                : 'No payout records found')),
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Disbursements and cash-out requests will be listed here.',
                    style: TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          if (cashOutRequests.isNotEmpty) ...[
            for (final request in cashOutRequests) ...[
              _FarmerCashOutRequestCard(request: request),
              const SizedBox(height: 12),
            ],
          ],
          for (final payout in payouts) ...[
            _FarmerPayoutCard(payout: payout),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _FarmerCashOutRequestCard extends StatelessWidget {
  const _FarmerCashOutRequestCard({required this.request});

  final FarmerCashOutRequest request;

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Pending';
    final monthNames = [
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
    final month = monthNames[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$month $day, $year';
  }

  void _openDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AgrisellColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FarmerCashOutDetailSheet(request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = request.isPaid
        ? AgrisellColors.statusGreenText
        : (request.isRejected
            ? const Color(0xFFE02424)
            : AgrisellColors.statusOrangeText);
    final statusBg = request.isPaid
        ? AgrisellColors.statusGreenBackground
        : (request.isRejected
            ? const Color(0xFFFDE8E8)
            : AgrisellColors.statusOrangeBackground);

    return Container(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AgrisellColors.authGreen.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AgrisellColors.statusGreenBackground,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Cash Out',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: AgrisellColors.authGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.methodLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AgrisellColors.mutedText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      request.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Requested Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: AgrisellColors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatBasketPeso(request.amount),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AgrisellColors.authGreen,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(request.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AgrisellColors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Account: ${request.accountName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AgrisellColors.brandBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmerCashOutDetailSheet extends StatelessWidget {
  const _FarmerCashOutDetailSheet({required this.request});

  final FarmerCashOutRequest request;

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Pending';
    final monthNames = [
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
    final month = monthNames[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = request.isPaid
        ? AgrisellColors.statusGreenText
        : (request.isRejected
            ? const Color(0xFFE02424)
            : AgrisellColors.statusOrangeText);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AgrisellColors.borderLine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Cash-Out Request Details',
                    style: TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: request.isPaid
                    ? AgrisellColors.statusGreenBackground
                    : AgrisellColors.statusOrangeBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Requested Amount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AgrisellColors.brandBlack,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          request.statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatBasketPeso(request.amount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Withdrawal Information',
              style: TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _SummaryLine(
              label: 'Payout Method',
              value: request.methodLabel,
            ),
            _SummaryLine(
              label: 'Account Name',
              value: request.accountName,
            ),
            _SummaryLine(
              label: 'Account Number',
              value: request.accountNumber,
            ),
            if (request.bankName.isNotEmpty)
              _SummaryLine(
                label: 'Bank Name',
                value: request.bankName,
              ),
            if (request.createdAt != null)
              _SummaryLine(
                label: 'Requested At',
                value: _formatDateTime(request.createdAt),
              ),
            if (request.notes.isNotEmpty)
              _SummaryLine(
                label: 'Notes',
                value: request.notes,
              ),
            if (request.rejectionReason.isNotEmpty)
              _SummaryLine(
                label: 'Rejection Reason',
                value: request.rejectionReason,
              ),
          ],
        ),
      ),
    );
  }
}

class _FarmerPayoutCard extends StatelessWidget {
  const _FarmerPayoutCard({required this.payout});

  final FarmerPayout payout;

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Pending';
    final monthNames = [
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
    final month = monthNames[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$month $day, $year';
  }

  void _copyReference(BuildContext context, String reference) {
    if (reference.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: reference.trim()));
    ScaffoldMessenger.of(context).showAppSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Payout reference copied to clipboard.'),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AgrisellColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FarmerPayoutDetailSheet(payout: payout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = payout.isPaid
        ? AgrisellColors.statusGreenText
        : (payout.isFailed
            ? AgrisellColors.statusOrangeText
            : AgrisellColors.statusOrangeText);
    final statusBg = payout.isPaid
        ? AgrisellColors.statusGreenBackground
        : (payout.isFailed
            ? const Color(0xFFFDE8E8)
            : AgrisellColors.statusOrangeBackground);

    return Container(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order: ${payout.clientOrderId.isNotEmpty ? payout.clientOrderId : 'ORD-${payout.orderId}'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AgrisellColors.mutedText,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      payout.status.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Net Payout',
                        style: TextStyle(
                          fontSize: 12,
                          color: AgrisellColors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatBasketPeso(payout.amount),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AgrisellColors.authGreen,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(payout.paidAt ?? payout.approvedAt ?? payout.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AgrisellColors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Customer: ${payout.buyerName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AgrisellColors.brandBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (payout.reference.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AgrisellColors.searchBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ref: ${payout.reference}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AgrisellColors.brandBlack,
                        ),
                      ),
                      InkWell(
                        onTap: () => _copyReference(context, payout.reference),
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 14,
                            color: AgrisellColors.authGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmerPayoutDetailSheet extends StatelessWidget {
  const _FarmerPayoutDetailSheet({required this.payout});

  final FarmerPayout payout;

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Pending';
    final monthNames = [
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
    final month = monthNames[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = payout.isPaid
        ? AgrisellColors.statusGreenText
        : (payout.isFailed
            ? AgrisellColors.statusOrangeText
            : AgrisellColors.statusOrangeText);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AgrisellColors.borderLine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Disbursement Details',
                    style: TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: payout.isPaid
                    ? AgrisellColors.statusGreenBackground
                    : AgrisellColors.statusOrangeBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Net Payout Amount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AgrisellColors.brandBlack,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          payout.status.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatBasketPeso(payout.amount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Disbursement Breakdown',
              style: TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _SummaryLine(
              label: 'Order ID',
              value: payout.clientOrderId.isNotEmpty
                  ? payout.clientOrderId
                  : 'ORD-${payout.orderId}',
            ),
            _SummaryLine(
              label: 'Customer',
              value: payout.buyerName,
            ),
            _SummaryLine(
              label: 'Gross Order Total',
              value: formatBasketPeso(payout.orderTotal),
            ),
            _SummaryLine(
              label: 'Net Disbursed',
              value: formatBasketPeso(payout.amount),
            ),
            if (payout.reference.isNotEmpty)
              _SummaryLine(
                label: 'Payout Reference',
                value: payout.reference,
              ),
            if (payout.paidAt != null)
              _SummaryLine(
                label: 'Paid At',
                value: _formatDateTime(payout.paidAt),
              ),
            if (payout.failureReason.isNotEmpty)
              _SummaryLine(
                label: 'Failure Note',
                value: payout.failureReason,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AgrisellColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AgrisellColors.brandBlack,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
