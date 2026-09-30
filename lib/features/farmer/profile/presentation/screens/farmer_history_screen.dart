import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/profile/domain/farmer_history_section.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_history_order_list.dart';
import 'package:agresell_app/features/farmer/reservations/data/farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/data/supabase_farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/controllers/farmer_rider_assignment_controller.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_rider_selection_screen.dart';
import 'package:agresell_app/features/farmer/reporting/farmer_financial_exporter.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/screens/farmer_reviews_screen.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';
import 'package:agresell_app/features/shared/reporting/widgets/export_report_sheet.dart';

class FarmerHistoryScreen extends StatefulWidget {
  const FarmerHistoryScreen({
    this.initialSection = FarmerHistorySection.toShip,
    this.controller,
    this.riderSelectionRepository,
    super.key,
  });

  final FarmerHistorySection initialSection;
  final OrderController? controller;
  final FarmerRiderSelectionRepository? riderSelectionRepository;

  @override
  State<FarmerHistoryScreen> createState() => _FarmerHistoryScreenState();
}

class _FarmerHistoryScreenState extends State<FarmerHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final OrderController _orders;
  late final FarmerRiderSelectionRepository _riderRepository;
  late final FarmerRiderAssignmentController _riders;
  late final Listenable _listenable;
  late final TabController _tabs;
  var _loading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _orders = widget.controller ?? OrderController.instance;
    _riderRepository =
        widget.riderSelectionRepository ??
        (AgrisellSupabase.isInitialized
            ? SupabaseFarmerRiderSelectionRepository(AgrisellSupabase.client)
            : const UnavailableFarmerRiderSelectionRepository());
    _riders = FarmerRiderAssignmentController(_riderRepository)..start();
    _listenable = Listenable.merge([_orders, _riders]);
    _tabs = TabController(
      length: FarmerHistorySection.values.length,
      initialIndex: FarmerHistorySection.values.indexOf(widget.initialSection),
      vsync: this,
    );
    unawaited(_reload());
  }

  @override
  void dispose() {
    _tabs.dispose();
    _riders.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    if (mounted) setState(() => _loading = true);
    try {
      await _orders.reload();
      if (mounted) setState(() => _loading = false);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = error;
      });
    }
  }

  void _exportOrdersCsv() {
    final report = FarmerFinancialExporter.buildOrdersSalesReport(
      orders: _orders.orders,
    );
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    ExportReportSheet.show(
      context,
      title: 'Farmer Sales & Orders Report',
      fileName: 'farmer_orders_$dateStr.csv',
      headers: report.headers,
      rows: report.rows,
      totalAmountLabel: formatBasketPeso(report.totalAmount),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    appBar: AppBar(
      backgroundColor: AgrisellColors.authGreen,
      foregroundColor: AgrisellColors.surface,
      title: const Text('My History'),
      actions: [
        IconButton(
          tooltip: 'Export Orders CSV',
          icon: const Icon(Icons.file_download_outlined),
          onPressed: _exportOrdersCsv,
        ),
      ],
      bottom: TabBar(
        controller: _tabs,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        indicatorColor: AgrisellColors.surface,
        labelColor: AgrisellColors.surface,
        unselectedLabelColor: AgrisellColors.surface,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: [
          for (final section in FarmerHistorySection.values)
            Tab(text: section.label),
        ],
      ),
    ),
    body: AnimatedBuilder(
      animation: _listenable,
      builder: (context, _) {
        if (_loading) return const Center(child: CircularProgressIndicator());
        if (_loadError != null) return _HistoryLoadFailure(onRetry: _reload);
        return TabBarView(
          controller: _tabs,
          children: [
            for (final section in FarmerHistorySection.values)
              if (section == FarmerHistorySection.feedback)
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AgrisellColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCDE4D7)),
                        boxShadow: [
                          BoxShadow(
                            color: AgrisellColors.brandBlack.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AgrisellColors.accentOrange,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reviews & Ratings Hub',
                                  style: TextStyle(
                                    color: AgrisellColors.headingGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'View star breakdown, buyer notes & moderation details',
                                  style: TextStyle(
                                    color: AgrisellColors.mutedText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonal(
                            onPressed: () {
                              Navigator.of(context).push(
                                agrisellPageRoute<void>(
                                  builder: (_) => const FarmerReviewsScreen(),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE8F5EE),
                              foregroundColor: AgrisellColors.authGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Open Hub', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FarmerHistoryOrderList(
                        section: section,
                        orders: _orders.orders.where(section.matches).toList(),
                        controller: _orders,
                        riderRequestFor: _riders.requestFor,
                        onChooseRider: _chooseRider,
                        onCancelRiderRequest: _cancelRiderRequest,
                        isCancellingRiderRequest: _riders.isCancelling,
                      ),
                    ),
                  ],
                )
              else
                FarmerHistoryOrderList(
                  section: section,
                  orders: _orders.orders.where(section.matches).toList(),
                  controller: _orders,
                  riderRequestFor: _riders.requestFor,
                  onChooseRider: _chooseRider,
                  onCancelRiderRequest: _cancelRiderRequest,
                  isCancellingRiderRequest: _riders.isCancelling,
                ),
          ],
        );
      },
    ),
  );

  Future<void> _chooseRider(PlacedOrder order) async {
    final request = await Navigator.of(context).push<FarmerRiderRequest>(
      agrisellPageRoute(
        builder: (_) => FarmerRiderSelectionScreen(
          orderId: order.id,
          repository: _riderRepository,
        ),
      ),
    );
    if (request != null) _riders.apply(request);
  }

  Future<void> _cancelRiderRequest(FarmerRiderRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel rider request?'),
        content: Text(
          'Cancel the pending request sent to ${request.riderName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep request'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _riders.cancel(request);
    } on Object catch (error) {
      if (!mounted) return;
      final detail = error.toString().replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            detail.isEmpty ? 'The request could not be cancelled.' : detail,
          ),
        ),
      );
    }
  }
}

class _HistoryLoadFailure extends StatelessWidget {
  const _HistoryLoadFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Unable to load order history.',
          style: TextStyle(color: AgrisellColors.mutedText, fontSize: 13),
        ),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}
