import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import '../styles/incident_tracking_styles.dart';

class IncidentResolutionStepper extends StatelessWidget {
  const IncidentResolutionStepper({super.key, required this.status});
  final SafetyIncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final step1Done = true;
    final step2Active =
        status == SafetyIncidentStatus.underReview ||
        status == SafetyIncidentStatus.waitingForInformation ||
        status == SafetyIncidentStatus.escalated;
    final step2Done = status.isTerminal;
    final step3Done = status == SafetyIncidentStatus.resolved;
    final step3Rejected = status == SafetyIncidentStatus.rejected;

    return Container(
      padding: IncidentTrackingStyles.stepperPadding,
      decoration: IncidentTrackingStyles.stepper,
      child: Row(
        children: [
          _stepNode(title: 'Reported', isDone: step1Done, isActive: false),
          _stepConnector(isDone: step2Active || step2Done),
          _stepNode(
            title: status == SafetyIncidentStatus.escalated
                ? 'Escalated'
                : 'Investigating',
            isDone: step2Done,
            isActive: step2Active,
          ),
          _stepConnector(isDone: step3Done || step3Rejected),
          _stepNode(
            title: step3Rejected ? 'Dismissed' : 'Resolved',
            isDone: step3Done,
            isActive: false,
            isRejected: step3Rejected,
          ),
        ],
      ),
    );
  }

  Widget _stepNode({
    required String title,
    required bool isDone,
    required bool isActive,
    bool isRejected = false,
  }) {
    final textStyle = isRejected
        ? IncidentTrackingStyles.rejectedStep
        : isDone
        ? IncidentTrackingStyles.completedStep
        : isActive
        ? IncidentTrackingStyles.activeStep
        : IncidentTrackingStyles.pendingStep;

    final icon = isRejected
        ? Icons.cancel_rounded
        : isDone
        ? Icons.check_circle_rounded
        : isActive
        ? Icons.autorenew_rounded
        : Icons.radio_button_unchecked_rounded;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: textStyle.color),
          const SizedBox(height: 2),
          Text(title, textAlign: TextAlign.center, style: textStyle),
        ],
      ),
    );
  }

  Widget _stepConnector({required bool isDone}) {
    return Container(
      width: 20,
      height: 2,
      color: isDone
          ? IncidentTrackingStyles.completedConnector
          : IncidentTrackingStyles.pendingConnector,
      margin: IncidentTrackingStyles.connectorMargin,
    );
  }
}
