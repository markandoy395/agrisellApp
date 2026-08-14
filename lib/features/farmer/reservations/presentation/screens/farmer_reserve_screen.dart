import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_quick_menu.dart';
import 'package:agresell_app/features/farmer/reservations/data/farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/data/supabase_farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/controllers/farmer_rider_assignment_controller.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_rider_selection_screen.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_order_details_screen.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_summary_card.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_cancellation_dialog.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/reserve_header.dart';

part 'farmer_reserve_empty_state.dart';

class FarmerReserveScreen extends StatefulWidget {
  const FarmerReserveScreen({
    this.controller,
    this.riderSelectionRepository,
    this.onNavigate,
    super.key,
  });

  final OrderController? controller;
  final FarmerRiderSelectionRepository? riderSelectionRepository;
  final ValueChanged<FarmerQuickDestination>? onNavigate;

  @override
  State<FarmerReserveScreen> createState() => _FarmerReserveScreenState();
}

class _FarmerReserveScreenState extends State<FarmerReserveScreen> {
  late final OrderController _orderController;
  late final FarmerRiderSelectionRepository _riderRepository;
  late final FarmerRiderAssignmentController _riderController;
  late final Listenable _screenListenable;
  final _searchController = TextEditingController();
  var _searchQuery = '';
  var _isLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _orderController = widget.controller ?? OrderController.instance;
    _riderRepository =
        widget.riderSelectionRepository ??
        (AgrisellSupabase.isInitialized
            ? SupabaseFarmerRiderSelectionRepository(AgrisellSupabase.client)
            : const UnavailableFarmerRiderSelectionRepository());
    _riderController = FarmerRiderAssignmentController(_riderRepository)
      ..start();
    _screenListenable = Listenable.merge([_orderController, _riderController]);
    unawaited(_reloadOrders());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _riderController.dispose();
    super.dispose();
  }

  Future<void> _reloadOrders() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      await _orderController.reload();
      if (!mounted) return;
      setState(() => _isLoading = false);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 12.0 : 14.0;
    final navClearance = 154.0 + MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: AgrisellColors.homeBackground,
      child: Column(
        children: [
          ReserveHeader(
            searchController: _searchController,
            onSearchChanged: (value) => setState(() => _searchQuery = value),
            onMenuTap: _openQuickMenu,
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _screenListenable,
              builder: (context, _) {
                if (_isLoading) {
                  return const _ReservationLoadingState();
                }
                if (_loadError != null) {
                  return _ReservationLoadFailure(onRetry: _reloadOrders);
                }
                final workflowOrders = _orderController.orders
                    .where(
                      (order) =>
                          order.status != PlacedOrderStatus.delivered &&
                          (order.status != PlacedOrderStatus.cancelled ||
                              order.payment.needsFarmerReview ||
                              order.payment.status ==
                                  OrderPaymentStatus.refundRequired),
                    )
                    .toList(growable: false);
                final visibleOrders = workflowOrders
                    .where(_matchesSearch)
                    .toList(growable: false);
                return CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        14,
                        horizontalPadding,
                        navClearance,
                      ),
                      sliver: visibleOrders.isEmpty
                          ? SliverToBoxAdapter(
                              child: _EmptyReservations(
                                hasSearch: _searchQuery.trim().isNotEmpty,
                              ),
                            )
                          : SliverList.separated(
                              itemCount: visibleOrders.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                return FarmerOrderSummaryCard(
                                  order: visibleOrders[index],
                                  onTap: () =>
                                      _openOrderDetails(visibleOrders[index]),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesSearch(PlacedOrder order) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    return order.id.toLowerCase().contains(query) ||
        order.buyerName.toLowerCase().contains(query) ||
        order.buyerId.toLowerCase().contains(query) ||
        order.deliveryAddress.toLowerCase().contains(query) ||
        order.phoneNumber.toLowerCase().contains(query) ||
        order.items.any(
          (item) =>
              item.productName.toLowerCase().contains(query) ||
              item.sellerName.toLowerCase().contains(query),
        );
  }

  Future<void> _openQuickMenu() async {
    final destination = await showFarmerQuickMenu(
      context,
      current: FarmerQuickDestination.reservations,
    );
    if (destination != null && mounted) widget.onNavigate?.call(destination);
  }

  Future<void> _chooseRider(PlacedOrder order) async {
    final request = await Navigator.of(context).push<FarmerRiderRequest>(
      agrisellPageRoute(
        builder: (_) => FarmerRiderSelectionScreen(
          orderId: order.id,
          repository: _riderRepository,
        ),
      ),
    );
    if (request != null) _riderController.apply(request);
  }

  Future<void> _openOrderDetails(PlacedOrder order) {
    return Navigator.of(context).push<void>(
      agrisellPageRoute(
        builder: (_) => FarmerOrderDetailsScreen(
          order: order,
          controller: _orderController,
          riderController: _riderController,
          onChooseRider: _chooseRider,
          onCancelRiderRequest: _cancelRiderRequest,
          onCancelOrder: _cancelOrder,
        ),
      ),
    );
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
      await _riderController.cancel(request);
    } on Object catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty ? 'The request could not be cancelled.' : message,
          ),
        ),
      );
    }
  }

  Future<void> _cancelOrder(PlacedOrder order) async {
    final reason = await showFarmerOrderCancellationDialog(context);
    if (reason == null || !mounted) return;
    try {
      await _orderController.cancelFarmerOrder(order.id, reason);
      await _riderController.refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('Order cancelled successfully.')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      final message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Bad state: ', '')
          .trim();
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty ? 'The order could not be cancelled.' : message,
          ),
        ),
      );
    }
  }
}
