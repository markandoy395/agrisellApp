import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import '../styles/incident_tracking_styles.dart';

class IncidentStatusBadge extends StatelessWidget {
  const IncidentStatusBadge({super.key, required this.status});
  final SafetyIncidentStatus status;

  @override
  Widget build(BuildContext context) => Container(
    padding: IncidentTrackingStyles.badgePadding,
    decoration: IncidentTrackingStyles.statusDecoration(status),
    child: Text(status.label, style: IncidentTrackingStyles.statusText(status)),
  );
}
