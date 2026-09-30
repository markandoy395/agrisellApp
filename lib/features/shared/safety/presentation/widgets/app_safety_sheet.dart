import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import 'package:agresell_app/features/shared/safety/presentation/controllers/safety_incident_controller.dart';
import 'package:agresell_app/features/shared/safety/presentation/screens/incident_tracking_screen.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';

enum SafetySheetAction {
  sos,
  reportIncident,
  viewHistory,
  contactSupport,
}

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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_rounded, color: AgrisellColors.authGreen, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Safety & Emergency Support',
                  style: TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Get immediate assistance, report an incident, or track resolution status.',
              style: TextStyle(color: AgrisellColors.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Emergency SOS Button
            Container(
              decoration: BoxDecoration(
                color: AgrisellColors.statusRedBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AgrisellColors.statusRedText.withValues(alpha: 0.3)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AgrisellColors.statusRedText,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sos_rounded, color: Colors.white, size: 24),
                ),
                title: const Text(
                  'Emergency SOS',
                  style: TextStyle(
                    color: AgrisellColors.statusRedText,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                subtitle: const Text(
                  'Trigger immediate high-priority safety alert to dispatch & admins',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () => Navigator.of(ctx).pop(SafetySheetAction.sos),
              ),
            ),
            const SizedBox(height: 12),

            // Report Incident
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AgrisellColors.pageBackground,
              leading: const Icon(Icons.report_problem_outlined, color: AgrisellColors.headingGreen),
              title: const Text(
                'Report a Safety Issue / Incident',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text('Accidents, harassment, suspicious activity, or property risk'),
              onTap: () => Navigator.of(ctx).pop(SafetySheetAction.reportIncident),
            ),
            const SizedBox(height: 8),

            // View Incident History & Status
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AgrisellColors.pageBackground,
              leading: const Icon(Icons.track_changes_rounded, color: AgrisellColors.forestGreen),
              title: const Text(
                'Incident History & Resolution Status',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text('Track progress and view admin investigation notes'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(ctx).pop(SafetySheetAction.viewHistory),
            ),
            const SizedBox(height: 8),

            // Contact Support
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AgrisellColors.pageBackground,
              leading: const Icon(Icons.support_agent_rounded, color: AgrisellColors.accentBlue),
              title: const Text(
                'Contact Customer Support',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text('Direct chat or helpline for non-emergency inquiries'),
              onTap: () => Navigator.of(ctx).pop(SafetySheetAction.contactSupport),
            ),
          ],
        ),
      ),
    ),
  );

  if (action == null || !context.mounted) return;

  switch (action) {
    case SafetySheetAction.sos:
      final confirmed = await _confirmSosDialog(context);
      if (confirmed != true || !context.mounted) return;
      final result = await safetyController.submitSOS(
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
            content: Text(safetyController.errorMessage ?? 'Failed to send SOS.'),
          ),
        );
      }

    case SafetySheetAction.reportIncident:
      final report = await _showIncidentReportDialog(
        context: context,
        role: role,
        orderId: orderId,
        deliveryId: deliveryId,
      );
      if (report == null || !context.mounted) return;
      final result = await safetyController.submitIncident(
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
              controller: safetyController,
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
            content: Text(safetyController.errorMessage ?? 'Failed to submit report.'),
          ),
        );
      }

    case SafetySheetAction.viewHistory:
      Navigator.of(context).push(
        agrisellPageRoute<void>(
          builder: (_) => IncidentTrackingScreen(
            controller: safetyController,
            role: role,
            userName: userName,
            userContact: userContact,
            userEmail: userEmail,
          ),
        ),
      );

    case SafetySheetAction.contactSupport:
      Navigator.of(context).push(
        agrisellPageRoute<void>(
          builder: (_) => const SupportCenterScreen(
            openCreateWithCategory: SupportTicketCategory.safety,
          ),
        ),
      );
  }
}

Future<bool?> _confirmSosDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AgrisellColors.statusRedText),
          const SizedBox(width: 8),
          const Text('Confirm Emergency SOS'),
        ],
      ),
      content: const Text(
        'This will immediately alert admin dispatch and emergency support with your account and order details. Are you in immediate distress?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AgrisellColors.statusRedText),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Yes, Send SOS Alert'),
        ),
      ],
    ),
  );
}

class _IncidentReportInput {
  const _IncidentReportInput({required this.category, required this.description});
  final SafetyIncidentCategory category;
  final String description;
}

Future<_IncidentReportInput?> _showIncidentReportDialog({
  required BuildContext context,
  required String role,
  int? orderId,
  int? deliveryId,
}) async {
  final categories = _categoriesForRole(role);
  var selectedCategory = categories.first;
  final controller = TextEditingController();

  return showDialog<_IncidentReportInput>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('Report Safety Incident'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Incident Category',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<SafetyIncidentCategory>(
                initialValue: selectedCategory,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat.label, style: const TextStyle(fontSize: 13)),
                      ),
                    )
                    .toList(),
                onChanged: (cat) {
                  if (cat != null) setDialogState(() => selectedCategory = cat);
                },
              ),
              const SizedBox(height: 14),
              const Text(
                'Describe the Incident',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Provide details on what happened, where, and any immediate actions needed…',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AgrisellColors.authGreen),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(ctx).pop(
                _IncidentReportInput(category: selectedCategory, description: text),
              );
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    ),
  );
}

List<SafetyIncidentCategory> _categoriesForRole(String role) => switch (role.toLowerCase()) {
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
