import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';

abstract final class IncidentTrackingStatusStyles {
  static const stepper = BoxDecoration(
    color: AgrisellColors.pageBackground,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  static const completedStep = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.forestGreen,
  );
  static const activeStep = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.accentOrange,
  );
  static const rejectedStep = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AgrisellColors.statusRedText,
  );
  static final pendingStep = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AgrisellColors.mutedText.withValues(alpha: 0.5),
  );
  static const completedConnector = AgrisellColors.forestGreen;
  static const pendingConnector = AgrisellColors.borderLine;

  static const _statusColors = {
    SafetyIncidentStatus.submitted: (
      AgrisellColors.statusBlueBackground,
      AgrisellColors.statusBlueText,
    ),
    SafetyIncidentStatus.underReview: (
      AgrisellColors.statusOrangeBackground,
      AgrisellColors.statusOrangeText,
    ),
    SafetyIncidentStatus.waitingForInformation: (
      AgrisellColors.statusOrangeBackground,
      AgrisellColors.statusOrangeText,
    ),
    SafetyIncidentStatus.escalated: (
      AgrisellColors.statusPurpleBackground,
      AgrisellColors.statusPurpleText,
    ),
    SafetyIncidentStatus.resolved: (
      AgrisellColors.statusGreenBackground,
      AgrisellColors.statusGreenText,
    ),
    SafetyIncidentStatus.rejected: (
      AgrisellColors.statusRedBackground,
      AgrisellColors.statusRedText,
    ),
  };

  static final _statusDecorations = {
    for (final entry in _statusColors.entries)
      entry.key: BoxDecoration(
        color: entry.value.$1,
        borderRadius: BorderRadius.circular(6),
      ),
  };

  static final _statusText = {
    for (final entry in _statusColors.entries)
      entry.key: TextStyle(
        color: entry.value.$2,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
  };

  static BoxDecoration statusDecoration(SafetyIncidentStatus status) =>
      _statusDecorations[status]!;
  static TextStyle statusText(SafetyIncidentStatus status) =>
      _statusText[status]!;
}
