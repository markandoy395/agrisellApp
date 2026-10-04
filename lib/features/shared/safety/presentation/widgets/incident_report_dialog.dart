import 'package:flutter/material.dart';
import '../../domain/safety_incident.dart';
import '../styles/incident_report_styles.dart';
import '../utils/app_safety_coordinator.dart';
import 'incident_report_sheet.dart';

class IncidentReportInput {
  const IncidentReportInput({
    required this.category,
    required this.description,
  });
  final SafetyIncidentCategory category;
  final String description;
}

Future<IncidentReportInput?> showIncidentReportDialog({
  required BuildContext context,
  required String role,
  int? orderId,
  int? deliveryId,
}) => showModalBottomSheet<IncidentReportInput>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  backgroundColor: Colors.white,
  shape: IncidentReportStyles.sheetShape,
  constraints: const BoxConstraints(maxWidth: 680),
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: FractionallySizedBox(
      heightFactor: 0.9,
      child: IncidentReportSheet(
        categories: AppSafetyCoordinator.categoriesForRole(role),
      ),
    ),
  ),
);
