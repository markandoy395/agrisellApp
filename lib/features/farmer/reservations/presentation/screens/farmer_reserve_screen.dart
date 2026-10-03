import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/widgets/farmer_quick_menu.dart';
import 'package:agresell_app/features/farmer/reservations/data/farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/data/supabase_farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/controllers/farmer_rider_assignment_controller.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_order_details_screen.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_reserve_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/utils/farmer_reserve_actions_handler.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_summary_card.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/reserve_header.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

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
    final horizontalPadding = FarmerReserveStyles.horizontalPadding(width);
    final navClearance = FarmerReserveStyles.navClearance(context);

    return ColoredBox(
      color: FarmerReserveStyles.backgroundColor,
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
                final visibleOrders =
                    FarmerReserveActionsHandler.filterWorkflowOrders(
                      _orderController.orders,
                      _searchQuery,
                    );
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
                                  FarmerReserveStyles.orderItemSpacing,
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

  Future<void> _openQuickMenu() async {
    final destination = await showFarmerQuickMenu(
      context,
      current: FarmerQuickDestination.reservations,
    );
    if (destination != null && mounted) widget.onNavigate?.call(destination);
  }

  Future<void> _openOrderDetails(PlacedOrder order) {
    return Navigator.of(context).push<void>(
      agrisellPageRoute(
        builder: (_) => FarmerOrderDetailsScreen(
          order: order,
          controller: _orderController,
          riderController: _riderController,
          onChooseRider: (order) => FarmerReserveActionsHandler.chooseRider(
            context: context,
            order: order,
            repository: _riderRepository,
            controller: _riderController,
          ),
          onCancelRiderRequest: (req) =>
              FarmerReserveActionsHandler.cancelRiderRequest(
                context: context,
                request: req,
                controller: _riderController,
                isMounted: () => mounted,
              ),
          onCancelOrder: (order) => FarmerReserveActionsHandler.cancelOrder(
            context: context,
            order: order,
            orderController: _orderController,
            riderController: _riderController,
            isMounted: () => mounted,
          ),
        ),
      ),
    );
  }
}
