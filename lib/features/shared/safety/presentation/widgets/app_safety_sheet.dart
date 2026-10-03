import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/safety/presentation/controllers/safety_incident_controller.dart';
import '../styles/app_safety_sheet_styles.dart';
import '../utils/app_safety_coordinator.dart';
import 'app_safety_sheet_content.dart';

export 'app_safety_sheet_content.dart' show SafetySheetAction;

Future<void> showAppSafetySheet({
  required BuildContext context,
  required String role,
  String? userName,
  String? userContact,
  String? userEmail,
  int? orderId,
  int? deliveryId,
  SafetyIncidentController? controller,
}) async {
  final safetyController = controller ?? SafetyIncidentController();

  final action = await showModalBottomSheet<SafetySheetAction>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: AppSafetySheetStyles.sheetShape,
    builder: (ctx) => AppSafetySheetContent(
      onSelectAction: (selected) => Navigator.of(ctx).pop(selected),
    ),
  );

  if (action == null || !context.mounted) return;

  switch (action) {
    case SafetySheetAction.sos:
      await AppSafetyCoordinator.handleSos(
        context: context,
        controller: safetyController,
        role: role,
        userName: userName,
        userContact: userContact,
        userEmail: userEmail,
        orderId: orderId,
        deliveryId: deliveryId,
      );

    case SafetySheetAction.reportIncident:
      await AppSafetyCoordinator.handleReportIncident(
        context: context,
        controller: safetyController,
        role: role,
        userName: userName,
        userContact: userContact,
        userEmail: userEmail,
        orderId: orderId,
        deliveryId: deliveryId,
      );

    case SafetySheetAction.viewHistory:
      AppSafetyCoordinator.navigateToHistory(
        context: context,
        controller: safetyController,
        role: role,
        userName: userName,
        userContact: userContact,
        userEmail: userEmail,
      );

    case SafetySheetAction.contactSupport:
      AppSafetyCoordinator.navigateToSupport(context);
  }
}
