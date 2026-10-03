export 'package:agresell_app/features/shared/orders/presentation/styles/notification_type_styles.dart';
import 'package:agresell_app/features/shared/orders/presentation/styles/notification_type_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';

class NotificationTypeIcon extends StatelessWidget {
  const NotificationTypeIcon({required this.style, super.key});

  final NotificationStyle style;

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: NotificationTypeStyles.containerDecoration(style),
    child: Icon(style.icon, color: style.color, size: 21),
  );
}

class NotificationTypeLabel extends StatelessWidget {
  const NotificationTypeLabel({required this.style, super.key});

  final NotificationStyle style;

  @override
  Widget build(BuildContext context) =>
      Text(style.label, style: NotificationTypeStyles.textStyle(style));
}

NotificationStyle notificationStyleFor(HomeNotificationType type) {
  return switch (type) {
    HomeNotificationType.newOrder => _green(
      Icons.receipt_long_outlined,
      'New order',
    ),
    HomeNotificationType.orderConfirmed => _green(
      Icons.task_alt_rounded,
      'Confirmed',
    ),
    HomeNotificationType.paymentUpdate => _green(
      Icons.payments_outlined,
      'Payment',
    ),
    HomeNotificationType.productApproved => _green(
      Icons.verified_outlined,
      'Approved',
    ),
    HomeNotificationType.productRejected => _red(
      Icons.cancel_outlined,
      'Rejected',
    ),
    HomeNotificationType.productSold => _green(Icons.sell_outlined, 'Sold'),
    HomeNotificationType.productOutOfStock => _orange(
      Icons.inventory_2_outlined,
      'Out of stock',
    ),
    HomeNotificationType.newMessage => _purple(
      Icons.chat_bubble_outline_rounded,
      'Message',
    ),
    HomeNotificationType.deliveryRequest => _blue(
      Icons.local_shipping_outlined,
      'Delivery',
    ),
    HomeNotificationType.riderAccepted => _green(
      Icons.delivery_dining_outlined,
      'Rider accepted',
    ),
    HomeNotificationType.riderArrived => _orange(
      Icons.location_on_outlined,
      'Rider arrived',
    ),
    HomeNotificationType.productPickedUp => _blue(
      Icons.inventory_2_outlined,
      'Picked up',
    ),
    HomeNotificationType.riderOnTheWay => _blue(
      Icons.route_outlined,
      'On the way',
    ),
    HomeNotificationType.productDelivered => _green(
      Icons.home_outlined,
      'Delivered',
    ),
    HomeNotificationType.deliveryCompleted => _green(
      Icons.check_circle_outline_rounded,
      'Completed',
    ),
    HomeNotificationType.deliveryCancelled => _red(
      Icons.cancel_outlined,
      'Cancelled',
    ),
    HomeNotificationType.verificationUpdate => _blue(
      Icons.verified_user_outlined,
      'Verification',
    ),
    HomeNotificationType.announcement => _blue(
      Icons.campaign_outlined,
      'Announcement',
    ),
    HomeNotificationType.warning => _orange(
      Icons.warning_amber_rounded,
      'Important',
    ),
  };
}

NotificationStyle _green(IconData icon, String label) => NotificationStyle(
  icon: icon,
  color: AgrisellColors.statusGreenText,
  background: AgrisellColors.statusGreenBackground,
  label: label,
);

NotificationStyle _blue(IconData icon, String label) => NotificationStyle(
  icon: icon,
  color: AgrisellColors.statusBlueText,
  background: AgrisellColors.statusBlueBackground,
  label: label,
);

NotificationStyle _orange(IconData icon, String label) => NotificationStyle(
  icon: icon,
  color: AgrisellColors.statusOrangeText,
  background: AgrisellColors.statusOrangeBackground,
  label: label,
);

NotificationStyle _red(IconData icon, String label) => NotificationStyle(
  icon: icon,
  color: AgrisellColors.statusRedText,
  background: AgrisellColors.statusRedBackground,
  label: label,
);

NotificationStyle _purple(IconData icon, String label) => NotificationStyle(
  icon: icon,
  color: AgrisellColors.statusPurpleText,
  background: AgrisellColors.statusPurpleBackground,
  label: label,
);
