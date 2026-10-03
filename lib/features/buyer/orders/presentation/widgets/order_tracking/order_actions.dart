part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _OrderCardActions extends StatelessWidget {
  const _OrderCardActions({
    required this.status,
    required this.canLeaveFeedback,
    required this.canRetryPayment,
    required this.onViewDetails,
    required this.onCancel,
    required this.onContactSeller,
    required this.onLeaveFeedback,
    required this.onRetryPayment,
    this.hasRefund = false,
    this.onTrackRefund,
    this.hasDispute = false,
    this.canDispute = false,
    this.onDispute,
  });

  final PlacedOrderStatus status;
  final bool canLeaveFeedback;
  final bool canRetryPayment;
  final bool hasRefund;
  final bool hasDispute;
  final bool canDispute;
  final VoidCallback onViewDetails;
  final VoidCallback onCancel;
  final VoidCallback onContactSeller;
  final VoidCallback onLeaveFeedback;
  final VoidCallback onRetryPayment;
  final VoidCallback? onTrackRefund;
  final VoidCallback? onDispute;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      _CompactActionButton(
        label: 'Details',
        icon: Icons.visibility_outlined,
        onPressed: onViewDetails,
      ),
      if (hasRefund && onTrackRefund != null)
        _CompactActionButton(
          label: 'Refund',
          icon: Icons.receipt_long_outlined,
          onPressed: onTrackRefund!,
          isFilled: true,
        ),
      if (status.canCancel)
        _CompactActionButton(
          label: 'Cancel',
          icon: Icons.close_rounded,
          onPressed: onCancel,
          isDestructive: true,
        ),
      if (canRetryPayment)
        _CompactActionButton(
          label: 'Fix payment',
          icon: Icons.account_balance_wallet_outlined,
          onPressed: onRetryPayment,
          isFilled: true,
        ),
      if (status != PlacedOrderStatus.cancelled)
        _CompactActionButton(
          label: 'Chat',
          icon: Icons.chat_bubble_outline_rounded,
          onPressed: onContactSeller,
        ),
      if (hasDispute && onDispute != null)
        _CompactActionButton(
          label: 'Dispute',
          icon: Icons.shield_outlined,
          onPressed: onDispute!,
          isFilled: true,
        )
      else if (canDispute && onDispute != null)
        _CompactActionButton(
          label: 'Dispute',
          icon: Icons.report_problem_outlined,
          onPressed: onDispute!,
        ),
      if (canLeaveFeedback)
        _CompactActionButton(
          label: 'Feedback',
          icon: Icons.rate_review_outlined,
          onPressed: onLeaveFeedback,
          isFilled: true,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth < 360 ? 4.0 : 8.0;
        return Row(
          children: [
            for (var index = 0; index < actions.length; index++) ...[
              if (index > 0) SizedBox(width: spacing),
              Expanded(child: actions[index]),
            ],
          ],
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.label});

  final PlacedOrderStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      PlacedOrderStatus.toPay => (
        text: AgrisellColors.statusOrangeText,
        background: AgrisellColors.statusOrangeBackground,
      ),
      PlacedOrderStatus.toShip => (
        text: AgrisellColors.statusGreenText,
        background: AgrisellColors.statusGreenBackground,
      ),
      PlacedOrderStatus.preparing => (
        text: AgrisellColors.statusOrangeText,
        background: AgrisellColors.statusOrangeBackground,
      ),
      PlacedOrderStatus.readyForPickup => (
        text: AgrisellColors.statusGreenText,
        background: AgrisellColors.statusGreenBackground,
      ),
      PlacedOrderStatus.shipping => (
        text: AgrisellColors.statusBlueText,
        background: AgrisellColors.statusBlueBackground,
      ),
      PlacedOrderStatus.delivered => (
        text: AgrisellColors.authGreen,
        background: AgrisellColors.limeSoft,
      ),
      PlacedOrderStatus.cancelled => (
        text: AgrisellColors.statusRedText,
        background: AgrisellColors.statusRedBackground,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: OrderActionsStyles.containerDecoration(colors),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 15, color: colors.text),
          const SizedBox(width: 6),
          Flexible(
            child: Tooltip(
              message: label,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OrderActionsStyles.labelText(colors),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(PlacedOrderStatus status) => switch (status) {
    PlacedOrderStatus.toPay => Icons.payments_outlined,
    PlacedOrderStatus.toShip => Icons.hourglass_top_rounded,
    PlacedOrderStatus.preparing => Icons.inventory_2_outlined,
    PlacedOrderStatus.readyForPickup => Icons.storefront_outlined,
    PlacedOrderStatus.shipping => Icons.route_rounded,
    PlacedOrderStatus.delivered => Icons.task_alt_rounded,
    PlacedOrderStatus.cancelled => Icons.cancel_outlined,
  };
}
