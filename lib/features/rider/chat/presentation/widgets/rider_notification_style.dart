import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';

class RiderNotificationStyle {
  const RiderNotificationStyle(this.icon, this.color);

  final IconData icon;
  final Color color;
}

RiderNotificationStyle riderNotificationStyleFor(RiderNotificationType type) =>
    switch (type) {
      RiderNotificationType.deliveryRequest => const RiderNotificationStyle(
        Icons.local_shipping_outlined,
        AgrisellColors.authGreen,
      ),
      RiderNotificationType.deliveryAccepted ||
      RiderNotificationType.productReady => const RiderNotificationStyle(
        Icons.task_alt_rounded,
        AgrisellColors.statusGreenText,
      ),
      RiderNotificationType.pickupReminder ||
      RiderNotificationType.dispute => const RiderNotificationStyle(
        Icons.inventory_2_outlined,
        AgrisellColors.statusOrangeText,
      ),
      RiderNotificationType.deliveryReminder ||
      RiderNotificationType.riderOnTheWay ||
      RiderNotificationType.offlineSyncResult => const RiderNotificationStyle(
        Icons.route_outlined,
        AgrisellColors.statusBlueText,
      ),
      RiderNotificationType.message ||
      RiderNotificationType.farmerMessage ||
      RiderNotificationType.buyerMessage ||
      RiderNotificationType.supportMessage => const RiderNotificationStyle(
        Icons.chat_bubble_outline_rounded,
        AgrisellColors.statusPurpleText,
      ),
      RiderNotificationType.cancellation ||
      RiderNotificationType.requestExpired ||
      RiderNotificationType.requestAcceptedByOther ||
      RiderNotificationType.urgentRequest => const RiderNotificationStyle(
        Icons.cancel_outlined,
        AgrisellColors.statusRedText,
      ),
      RiderNotificationType.payment ||
      RiderNotificationType.earningsAdjustment => const RiderNotificationStyle(
        Icons.payments_outlined,
        AgrisellColors.statusGreenText,
      ),
      RiderNotificationType.verification => const RiderNotificationStyle(
        Icons.verified_outlined,
        AgrisellColors.statusBlueText,
      ),
      RiderNotificationType.rating => const RiderNotificationStyle(
        Icons.star_outline_rounded,
        AgrisellColors.statusOrangeText,
      ),
      RiderNotificationType.reassignment ||
      RiderNotificationType.safetyUpdate => const RiderNotificationStyle(
        Icons.support_agent_rounded,
        AgrisellColors.statusOrangeText,
      ),
      RiderNotificationType.riderArrivedAtPickup =>
        const RiderNotificationStyle(
          Icons.location_on_outlined,
          AgrisellColors.statusOrangeText,
        ),
      RiderNotificationType.productPickedUp => const RiderNotificationStyle(
        Icons.inventory_2_outlined,
        AgrisellColors.statusBlueText,
      ),
      RiderNotificationType.productDelivered ||
      RiderNotificationType.deliveryCompleted => const RiderNotificationStyle(
        Icons.check_circle_outline_rounded,
        AgrisellColors.statusGreenText,
      ),
    };
