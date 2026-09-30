part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _OrdersForFilter extends StatelessWidget {
  const _OrdersForFilter({
    required this.filter,
    required this.orders,
    required this.onCancelOrder,
    required this.onSubmitFeedback,
    this.onReportDispute,
  });

  final OrderTrackingFilter filter;
  final List<PlacedOrder> orders;
  final Future<void> Function(String orderId) onCancelOrder;
  final _SubmitOrderFeedback onSubmitFeedback;
  final _ReportOrderDispute? onReportDispute;

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final order in orders)
        for (final item in order.items)
          _OrderItemEntry(order: order, item: item),
    ];

    if (entries.isEmpty) {
      return _EmptyOrderState(filter: filter);
    }

    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 10.0 : 14.0;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontalPadding, 2, horizontalPadding, 24),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _TrackingOrderCard(
          key: ValueKey('${entry.order.id}-${entry.item.productId}'),
          order: entry.order,
          item: entry.item,
          onCancelOrder: onCancelOrder,
          onSubmitFeedback: onSubmitFeedback,
          onReportDispute: onReportDispute,
        );
      },
    );
  }
}

class _OrderItemEntry {
  const _OrderItemEntry({required this.order, required this.item});

  final PlacedOrder order;
  final PlacedOrderItem item;
}
