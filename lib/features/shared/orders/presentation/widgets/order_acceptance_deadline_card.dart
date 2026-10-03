import 'package:agresell_app/features/shared/orders/presentation/styles/order_acceptance_deadline_card_styles.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

enum OrderDeadlineAudience { buyer, farmer }

class OrderAcceptanceDeadlineCard extends StatefulWidget {
  const OrderAcceptanceDeadlineCard({
    required this.order,
    required this.audience,
    super.key,
  });

  final PlacedOrder order;
  final OrderDeadlineAudience audience;

  @override
  State<OrderAcceptanceDeadlineCard> createState() =>
      _OrderAcceptanceDeadlineCardState();
}

class _OrderAcceptanceDeadlineCardState
    extends State<OrderAcceptanceDeadlineCard> {
  Timer? _ticker;
  var _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final deadline = order.acceptanceExpiresAt;
    if (deadline == null ||
        (!order.isExpired && order.status != PlacedOrderStatus.toShip)) {
      return const SizedBox.shrink();
    }
    final overdue = !order.isExpired && !_now.isBefore(deadline);
    final urgent =
        overdue || deadline.difference(_now) <= const Duration(minutes: 30);
    final foreground = order.isExpired || overdue
        ? AgrisellColors.statusRedText
        : urgent
        ? AgrisellColors.statusOrangeText
        : AgrisellColors.statusBlueText;
    final title = order.isExpired
        ? 'Deadline expired'
        : overdue
        ? 'Response overdue'
        : '${_remaining(deadline)} left';
    final detail = order.isExpired
        ? _expiredMessage(order.payment.status)
        : overdue
        ? 'Deadline passed. The server will close this order shortly.'
        : widget.audience == OrderDeadlineAudience.farmer
        ? 'Accept the order before this time.'
        : 'Waiting for the farmer to respond.';
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(deadline);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(deadline),
    );
    final infoText = '$detail Deadline: $date at $time.';
    final infoIcon = order.isExpired || overdue
        ? Icons.error_outline_rounded
        : urgent
        ? Icons.warning_amber_rounded
        : Icons.info_outline_rounded;

    return Semantics(
      container: true,
      liveRegion: urgent || order.isExpired,
      label: '$title. $detail. Deadline $date at $time.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              order.isExpired ? Icons.timer_off_outlined : Icons.timer_outlined,
              size: 21,
              color: foreground,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OrderAcceptanceDeadlineCardStyles.titleText(foreground),
              ),
            ),
            Tooltip(
              message: infoText,
              child: IconButton(
                key: const ValueKey('order-deadline-info'),
                onPressed: () => _showInfo(context, infoText),
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                padding: EdgeInsets.zero,
                icon: Icon(infoIcon, size: 18, color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _remaining(DateTime deadline) {
    final remaining = deadline.difference(_now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60).clamp(0, 59);
    if (hours <= 0) return '$minutes min';
    return '${hours}h ${minutes}m';
  }

  void _showInfo(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  String _expiredMessage(OrderPaymentStatus status) => switch (status) {
    OrderPaymentStatus.paymentReviewRequired =>
      'Stock was released. The submitted GCash payment needs review.',
    OrderPaymentStatus.refundRequired =>
      'Stock was released. The verified GCash payment requires a refund.',
    OrderPaymentStatus.refunded =>
      'Stock was released and the GCash refund was completed.',
    _ => 'Reserved stock was released for other buyers.',
  };
}
