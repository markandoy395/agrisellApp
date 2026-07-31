import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/farmer/reservations/data/farmer_reservations.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_reservation.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/buyer_message_sheet.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_card.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/reserve_header.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/reserved_order_card.dart';

part 'farmer_reserve_empty_state.dart';

class FarmerReserveScreen extends StatefulWidget {
  const FarmerReserveScreen({super.key});

  @override
  State<FarmerReserveScreen> createState() => _FarmerReserveScreenState();
}

class _FarmerReserveScreenState extends State<FarmerReserveScreen> {
  late final List<FarmerReservation> _orders;
  final _orderController = OrderController.instance;

  @override
  void initState() {
    super.initState();
    _orders = [...farmerReservations];
    unawaited(_orderController.reload());
  }

  Future<void> _confirmOrder(FarmerReservation order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _ConfirmDeliveryDialog(),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      final index = _orders.indexWhere((item) => item.id == order.id);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(
          status: FarmerReservationStatus.toShip,
        );
      }
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(
      SnackBar(content: Text('${order.buyerName} order moved to To Ship.')),
    );
  }

  void _openBuyerMessages(FarmerReservation order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AgrisellColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BuyerMessageSheet(order: order),
    );
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
                      sliver: _orders.isEmpty && workflowOrders.isEmpty
                          ? const SliverToBoxAdapter(
                              child: _EmptyReservations(),
                            )
                          : SliverList.separated(
                              itemCount: _orders.length + workflowOrders.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                if (index < workflowOrders.length) {
                                  return FarmerOrderWorkflowCard(
                                    order: workflowOrders[index],
                                  );
                                }
                                final order =
                                    _orders[index - workflowOrders.length];
                                return ReservedOrderCard(
                                  order: order,
                                  onMessageBuyer: () =>
                                      _openBuyerMessages(order),
                                  onConfirmOrder: order.canConfirm
                                      ? () => _confirmOrder(order)
                                      : null,
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

class _ConfirmDeliveryDialog extends StatelessWidget {
  const _ConfirmDeliveryDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AgrisellColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Confirm delivery',
        style: TextStyle(
          color: AgrisellColors.headingGreen,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: const Text(
        'Are you sure you want to confirm this order for delivery?',
        style: TextStyle(
          color: AgrisellColors.brandBlack,
          fontSize: 13,
          height: 1.35,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: AgrisellColors.authGreen,
            foregroundColor: AgrisellColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
