import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import '../styles/incident_tracking_styles.dart';
import '../utils/incident_tracking_formatters.dart';
import 'incident_resolution_audit.dart';
import 'incident_resolution_stepper.dart';
import 'incident_status_badge.dart';

class IncidentTrackingCard extends StatelessWidget {
  const IncidentTrackingCard({super.key, required this.incident});

  final SafetyIncident incident;

  @override
  Widget build(BuildContext context) {
    final isEmergency = incident.isEmergency;
    final isResolved = incident.status.isTerminal;

    return Container(
      margin: IncidentTrackingStyles.cardMargin,
      decoration: isEmergency && !isResolved
          ? IncidentTrackingStyles.emergencyCard
          : IncidentTrackingStyles.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Container(
            padding: IncidentTrackingStyles.cardHeaderPadding,
            decoration: isEmergency && !isResolved
                ? IncidentTrackingStyles.emergencyCardHeader
                : IncidentTrackingStyles.cardHeader,
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Category Tag
                      Container(
                        padding: IncidentTrackingStyles.badgePadding,
                        decoration: isEmergency
                            ? IncidentTrackingStyles.emergencyCategory
                            : IncidentTrackingStyles.category,
                        child: Text(
                          isEmergency
                              ? '🚨 ${incident.category.label}'
                              : incident.category.label,
                          style: IncidentTrackingStyles.categoryText,
                        ),
                      ),
                      // Status Chip
                      IncidentStatusBadge(status: incident.status),
                    ],
                  ),
                ),
                Text(
                  formatIncidentTimeAgo(incident.reportedAt),
                  style: IncidentTrackingStyles.mutedText,
                ),
              ],
            ),
          ),

          Padding(
            padding: IncidentTrackingStyles.cardBodyPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report ID & references
                Row(
                  children: [
                    Text(
                      'ID: ${incident.reportId}',
                      style: IncidentTrackingStyles.reportId,
                    ),
                    if (incident.orderId != null) ...[
                      const Text(
                        ' • ',
                        style: IncidentTrackingStyles.referenceSeparator,
                      ),
                      Text(
                        'Order #${incident.orderId}',
                        style: IncidentTrackingStyles.orderReference,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Multi-stage Resolution Stepper
                IncidentResolutionStepper(status: incident.status),
                const SizedBox(height: 12),

                // Description
                const Text(
                  'REPORT STATEMENT',
                  style: IncidentTrackingStyles.statementLabel,
                ),
                const SizedBox(height: 4),
                Text(
                  incident.description,
                  style: IncidentTrackingStyles.description,
                ),

                // Admin Resolution Audit Notes (if provided)
                if (incident.resolutionNotes?.isNotEmpty == true) ...[
                  const SizedBox(height: 14),
                  IncidentResolutionAudit(incident: incident),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
