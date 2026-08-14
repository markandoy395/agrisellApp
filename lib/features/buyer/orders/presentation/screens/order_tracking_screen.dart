import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/order_status.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/order_acceptance_deadline_card.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_thumbnail.dart';
import 'package:agresell_app/features/buyer/chat/presentation/buyer_conversation_launcher.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/common/buyer_responsive_text.dart';
import 'package:agresell_app/features/buyer/orders/presentation/widgets/gcash_reference_retry_sheet.dart';

part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/order_tracking_header.dart';
part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/order_status_tabs.dart';
part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/orders_for_status.dart';
part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/tracking_order_card.dart';
part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/order_item_summary.dart';
part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/delivery_route_tracker.dart';
part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/order_actions.dart';
part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/compact_order_action_button.dart';
part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/order_details_sheet.dart';
part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/order_feedback_sheet.dart';
part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/order_feedback_product_header.dart';
part 'package:agresell_app/features/buyer/orders/presentation/widgets/order_tracking/empty_order_state.dart';

const _orderTrackingTabs = OrderTrackingFilter.values;

typedef _SubmitOrderFeedback =
    Future<void> Function({
      required String orderId,
      required String productId,
      required int rating,
      required String comment,
      int? riderRating,
      String riderComment,
      bool reviewProduct,
    });

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({
    this.initialFilter = OrderTrackingFilter.toShip,
    super.key,
  });

  final OrderTrackingFilter initialFilter;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  final _orderController = OrderController.instance;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    unawaited(_orderController.reload());
    final initialIndex = _orderTrackingTabs.indexOf(widget.initialFilter);
    _tabController = TabController(
      length: _orderTrackingTabs.length,
      initialIndex: initialIndex == -1 ? 0 : initialIndex,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BuyerResponsiveText(
      child: Scaffold(
        backgroundColor: AgrisellColors.homeBackground,
        body: Column(
          children: [
            const _OrderTrackingHeader(),
            _OrderStatusTabs(controller: _tabController),
            Expanded(
              child: AnimatedBuilder(
                animation: _orderController,
                builder: (context, _) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      for (final filter in _orderTrackingTabs)
                        _OrdersForFilter(
                          filter: filter,
                          orders: _orderController.ordersForFilter(filter),
                          onCancelOrder: _orderController.cancelOrder,
                          onSubmitFeedback: _orderController.submitFeedback,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
