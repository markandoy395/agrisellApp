import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_card.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/reserve_header.dart';

part 'farmer_reserve_empty_state.dart';

class FarmerReserveScreen extends StatefulWidget {
  const FarmerReserveScreen({this.controller, super.key});

  final OrderController? controller;

  @override
  State<FarmerReserveScreen> createState() => _FarmerReserveScreenState();
}

class _FarmerReserveScreenState extends State<FarmerReserveScreen> {
  late final OrderController _orderController;
  var _isLoading = true;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _orderController = widget.controller ?? OrderController.instance;
    unawaited(_reloadOrders());
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
          const ReserveHeader(),
          Expanded(
            child: AnimatedBuilder(
              animation: _orderController,
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
                      sliver: workflowOrders.isEmpty
                          ? const SliverToBoxAdapter(
                              child: _EmptyReservations(),
                            )
                          : SliverList.separated(
                              itemCount: workflowOrders.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                return FarmerOrderWorkflowCard(
                                  order: workflowOrders[index],
                                  controller: _orderController,
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
}
