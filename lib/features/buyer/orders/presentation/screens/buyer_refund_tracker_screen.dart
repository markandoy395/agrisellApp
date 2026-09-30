import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/buyer/orders/presentation/widgets/buyer_refund_detail_sheet.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/product_thumbnail.dart';

enum BuyerRefundFilter { all, completed, inProgress }

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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'All Refunds'),
            Tab(text: 'Completed'),
            Tab(text: 'In Progress'),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _orderController,
        builder: (context, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              for (final filter in BuyerRefundFilter.values)
                _RefundOrderListView(
                  orders: _filterOrders(_orderController.orders, filter),
                  filter: filter,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RefundOrderListView extends StatelessWidget {
  const _RefundOrderListView({
    required this.orders,
    required this.filter,
  });

  final List<PlacedOrder> orders;
  final BuyerRefundFilter filter;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AgrisellColors.searchBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 32,
                  color: AgrisellColors.mutedText,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                filter == BuyerRefundFilter.completed
                    ? 'No completed refunds'
                    : (filter == BuyerRefundFilter.inProgress
                        ? 'No refunds in progress'
                        : 'No refund records found'),
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cancelled orders eligible for GCash refunds will appear here with live tracking status.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _RefundOrderCard(order: order);
      },
    );
  }
}

class _RefundOrderCard extends StatelessWidget {
  const _RefundOrderCard({required this.order});

  final PlacedOrder order;

  void _copyReference(BuildContext context, String reference) {
    if (reference.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: reference.trim()));
    ScaffoldMessenger.of(context).showAppSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Refund reference copied to clipboard.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payment = order.payment;
    final isCompleted = payment.isRefundCompleted;
    final isApproved = payment.status == OrderPaymentStatus.refundRequired ||
        payment.refundStatus.toLowerCase() == 'approved';
    final refundAmount = payment.refundAmount ?? order.total;
    final refundRef = payment.refundReference.isNotEmpty
        ? payment.refundReference
        : (payment.transactionReference.isNotEmpty
            ? payment.transactionReference
            : '');
    final firstItem = order.items.isNotEmpty ? order.items.first : null;

    return Container(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AgrisellColors.statusGreenBackground
                        : (isApproved
                            ? AgrisellColors.statusOrangeBackground
                            : AgrisellColors.statusPurpleBackground),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isCompleted
                        ? 'Refund Completed'
                        : (isApproved ? 'Refund Approved' : 'In Progress'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isCompleted
                          ? AgrisellColors.statusGreenText
                          : (isApproved
                              ? AgrisellColors.statusOrangeText
                              : AgrisellColors.statusPurpleText),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (firstItem != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProductThumbnail.square(
                    asset: firstItem.image,
                    imageUrl: firstItem.imageUrl,
                    size: 52,
                    borderRadius: 8,
                    semanticLabel: '${firstItem.productName} photo',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AgrisellColors.brandBlack,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${order.totalQuantity} items · ${formatBasketPeso(order.total)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AgrisellColors.mutedText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AgrisellColors.searchBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Refund Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: AgrisellColors.mutedText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatBasketPeso(refundAmount),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AgrisellColors.authGreen,
                        ),
                      ),
                    ],
                  ),
                  if (refundRef.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          'Ref: $refundRef',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AgrisellColors.brandBlack,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _copyReference(context, refundRef),
                          child: const Padding(
                            padding: EdgeInsets.all(3),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 14,
                              color: AgrisellColors.authGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton.icon(
                onPressed: () => showBuyerRefundDetailSheet(context, order: order),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AgrisellColors.authGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(
                  Icons.timeline_rounded,
                  size: 16,
                  color: AgrisellColors.authGreen,
                ),
                label: const Text(
                  'Track Refund Status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AgrisellColors.authGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
