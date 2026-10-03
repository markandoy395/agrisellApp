import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import 'package:agresell_app/features/shared/safety/presentation/controllers/safety_incident_controller.dart';
import 'package:agresell_app/features/shared/safety/presentation/screens/incident_tracking_screen.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/confirm_sos_dialog.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/incident_report_dialog.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';

abstract final class AppSafetyCoordinator {
  static List<SafetyIncidentCategory> categoriesForRole(String role) =>
      switch (role.toLowerCase()) {
        'buyer' => const [
          SafetyIncidentCategory.harassment,
          SafetyIncidentCategory.suspiciousUser,
          SafetyIncidentCategory.fraudScam,
          SafetyIncidentCategory.unsafeDestination,
          SafetyIncidentCategory.damagedGoods,
          SafetyIncidentCategory.severeWeather,
          SafetyIncidentCategory.other,
        ],
        'farmer' => const [
          SafetyIncidentCategory.theft,
          SafetyIncidentCategory.harassment,
          SafetyIncidentCategory.unsafePickup,
          SafetyIncidentCategory.roadClosure,
          SafetyIncidentCategory.severeWeather,
          SafetyIncidentCategory.fraudScam,
          SafetyIncidentCategory.other,
        ],
        _ => const [
          SafetyIncidentCategory.accident,
          SafetyIncidentCategory.vehicleBreakdown,
          SafetyIncidentCategory.roadClosure,
          SafetyIncidentCategory.unsafePickup,
          SafetyIncidentCategory.unsafeDestination,
          SafetyIncidentCategory.harassment,
          SafetyIncidentCategory.theft,
          SafetyIncidentCategory.severeWeather,
          SafetyIncidentCategory.other,
        ],
      };

  static Future<void> handleSos({
    required BuildContext context,
    required SafetyIncidentController controller,
    required String role,
    String? userName,
    String? userContact,
    String? userEmail,
    int? orderId,
    int? deliveryId,
  }) async {
    final confirmed = await showConfirmSosDialog(context);
    if (confirmed != true || !context.mounted) return;

    final result = await controller.submitSOS(
      reporterRole: role,
      reporterName: userName,
      reporterContact: userContact,
      reporterEmail: userEmail,
      orderId: orderId,
      deliveryId: deliveryId,
    );
    if (!context.mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(
          content: Text('🚨 Emergency SOS broadcast sent! Dispatch has been alerted.'),
          backgroundColor: AgrisellColors.statusRedText,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Failed to send SOS.'),
        ),
      );
    }
  }

  static Future<void> handleReportIncident({
    required BuildContext context,
    required SafetyIncidentController controller,
    required String role,
    String? userName,
    String? userContact,
    String? userEmail,
    int? orderId,
    int? deliveryId,
  }) async {
    final report = await showIncidentReportDialog(
      context: context,
      role: role,
      orderId: orderId,
      deliveryId: deliveryId,
    );
    if (report == null || !context.mounted) return;

    final result = await controller.submitIncident(
      category: report.category,
      description: report.description,
      reporterRole: role,
      reporterName: userName,
      reporterContact: userContact,
      reporterEmail: userEmail,
      orderId: orderId,
      deliveryId: deliveryId,
    );
    if (!context.mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text('Safety report submitted (ID: ${result.reportId}). Tracking opened.'),
          backgroundColor: AgrisellColors.forestGreen,
        ),
      );
      Navigator.of(context).push(
        agrisellPageRoute<void>(
          builder: (_) => IncidentTrackingScreen(
            controller: controller,
            role: role,
            userName: userName,
            userContact: userContact,
            userEmail: userEmail,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Failed to submit report.'),
        ),
      );
    }
  }

  static void navigateToHistory({
    required BuildContext context,
    required SafetyIncidentController controller,
    required String role,
    String? userName,
    String? userContact,
    String? userEmail,
  }) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => IncidentTrackingScreen(
          controller: controller,
          role: role,
          userName: userName,
          userContact: userContact,
          userEmail: userEmail,
        ),
      ),
    );
  }

  static void navigateToSupport(BuildContext context) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => const SupportCenterScreen(
          openCreateWithCategory: SupportTicketCategory.safety,
        ),
      ),
    );
  }
}
