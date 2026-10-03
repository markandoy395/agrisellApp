import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import '../styles/incident_tracking_styles.dart';
import '../utils/incident_tracking_formatters.dart';

class IncidentResolutionAudit extends StatelessWidget {
  const IncidentResolutionAudit({super.key, required this.incident});
  final SafetyIncident incident;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: IncidentTrackingStyles.auditPadding,
    decoration: IncidentTrackingStyles.audit,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.verified_rounded,
              size: 16,
              color: IncidentTrackingStyles.green,
            ),
            const SizedBox(width: 6),
            const Text(
              'ADMIN RESOLUTION AUDIT NOTE',
              style: IncidentTrackingStyles.auditTitle,
            ),
            if (incident.resolvedBy != null) ...[
              Text(
                ' • by ${incident.resolvedBy}',
                style: IncidentTrackingStyles.auditAuthor,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          incident.resolutionNotes!,
          style: IncidentTrackingStyles.description,
        ),
        if (incident.resolvedAt != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Resolved at ${formatIncidentDateTime(incident.resolvedAt!)}',
              style: IncidentTrackingStyles.mutedText,
            ),
          ),
        ],
      ],
    ),
  );
}
