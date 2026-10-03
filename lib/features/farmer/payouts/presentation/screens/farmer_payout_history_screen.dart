import 'package:flutter/material.dart';

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

import '../styles/payout_surface_styles.dart';
import '../utils/farmer_payout_filter.dart';
import '../widgets/payout_history_app_bar.dart';
import '../widgets/payout_history_body.dart';

export '../utils/farmer_payout_filter.dart' show FarmerPayoutFilter;

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
    _repository =
        widget.repository ??
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

  Future<void> _openCashOutDialog() async {
    final result = await showModalBottomSheet<FarmerCashOutRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PayoutSurfaceStyles.transparent,
      builder: (_) =>
          FarmerCashOutDialog(onSubmit: _repository.submitCashOutRequest),
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
    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: PayoutHistoryAppBar(
        onExport: _exportPayoutsCsv,
        onCashOut: _openCashOutDialog,
        onRefresh: _loadPayouts,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AgrisellColors.authGreen),
            )
          : PayoutHistoryBody(
              payouts: _payouts,
              cashOutRequests: _cashOutRequests,
              tabController: _tabController,
              onCashOut: _openCashOutDialog,
              onRefresh: _loadPayouts,
            ),
    );
  }
}
