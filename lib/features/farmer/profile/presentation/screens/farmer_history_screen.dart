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
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

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

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    appBar: AppBar(
      backgroundColor: AgrisellColors.authGreen,
      foregroundColor: AgrisellColors.surface,
      title: const Text('My History'),
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
