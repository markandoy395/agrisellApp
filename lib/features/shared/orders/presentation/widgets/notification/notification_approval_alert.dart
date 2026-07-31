import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/features/shared/orders/data/home_notification_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';

Future<void> showFarmerApprovalAlertForUser(
  BuildContext context,
  String? userId,
) async {
  const repository = HomeNotificationRepository();
  try {
    final notifications = await repository.loadForUser(userId);
    if (context.mounted) {
      await showFarmerApprovalAlert(context, repository, notifications);
    }
  } catch (_) {
    // The notification feed will retry the request when the tab is opened.
  }
}

Future<void> showFarmerApprovalAlert(
  BuildContext context,
  HomeNotificationRepository repository,
  Iterable<HomeNotification> notifications,
) async {
  final approval = repository.firstUnreadFarmerApproval(notifications);
  if (approval == null || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showAppSnackBar(SnackBar(content: Text(approval.description)));
  final userId = approval.recipientId;
  if (userId != null) {
    await repository.setRead(userId, approval.id, isRead: true);
  }
}
