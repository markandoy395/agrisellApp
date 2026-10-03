import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/orders/presentation/styles/buyer_refund_tracker_styles.dart';
import 'package:agresell_app/features/buyer/orders/presentation/widgets/buyer_refund_order_list_view.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

export 'package:agresell_app/features/buyer/orders/presentation/widgets/buyer_refund_order_list_view.dart'
    show BuyerRefundFilter;

class BuyerRefundTrackerScreen extends StatefulWidget {
  const BuyerRefundTrackerScreen({
    this.initialFilter = BuyerRefundFilter.all,
    super.key,
  });

  final BuyerRefundFilter initialFilter;

  @override
  State<BuyerRefundTrackerScreen> createState() =>
      _BuyerRefundTrackerScreenState();
}

class _BuyerRefundTrackerScreenState extends State<BuyerRefundTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _orderController = OrderController.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: BuyerRefundFilter.values.length,
      initialIndex: widget.initialFilter.index,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<PlacedOrder> _filterOrders(
    List<PlacedOrder> orders,
    BuyerRefundFilter filter,
  ) {
    final refundOrders = orders.where((order) {
      final payment = order.payment;
      return payment.status == OrderPaymentStatus.refundRequired ||
          payment.status == OrderPaymentStatus.refunded ||
          payment.refundReference.isNotEmpty ||
          (order.status == PlacedOrderStatus.cancelled &&
              payment.method == OrderPaymentMethod.gcash);
    }).toList();

    return switch (filter) {
      BuyerRefundFilter.all => refundOrders,
      BuyerRefundFilter.completed =>
        refundOrders.where((order) => order.payment.isRefundCompleted).toList(),
      BuyerRefundFilter.inProgress =>
        refundOrders.where((order) => !order.payment.isRefundCompleted).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(
        title: const Text(
          'Refund Tracker',
          style: BuyerRefundTrackerStyles.appBarTitleStyle,
        ),
        backgroundColor: AgrisellColors.authGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: BuyerRefundTrackerStyles.tabLabelStyle,
          tabs: const [
            Tab(text: 'All Refunds'),
            Tab(text: 'Completed'),
            Tab(text: 'In Progress'),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _orderController,
        builder: (context, _) => TabBarView(
          controller: _tabController,
          children: [
            for (final filter in BuyerRefundFilter.values)
              BuyerRefundOrderListView(
                orders: _filterOrders(_orderController.orders, filter),
                filter: filter,
              ),
          ],
        ),
      ),
    );
  }
}
