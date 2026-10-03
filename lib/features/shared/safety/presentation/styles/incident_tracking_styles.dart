import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import 'package:agresell_app/features/shared/safety/presentation/styles/incident_tracking_status_styles.dart';

export 'package:agresell_app/features/shared/safety/presentation/styles/incident_tracking_status_styles.dart';

/// Shared visual definitions and predefined incident state variants.
abstract final class IncidentTrackingStyles {
  static const background = AgrisellColors.homeBackground;
  static const surface = AgrisellColors.surface;
  static const heading = AgrisellColors.headingGreen;
  static const green = AgrisellColors.forestGreen;
  static const white = Colors.white;
  static const selectedFilterColor = AgrisellColors.authGreen;
  static const filterBackground = AgrisellColors.pageBackground;

  static const filterPadding = EdgeInsets.fromLTRB(16, 8, 16, 12);
  static const emptyIconPadding = EdgeInsets.all(20);
  static const emptyMessagePadding = EdgeInsets.symmetric(horizontal: 40);
  static const listPadding = EdgeInsets.fromLTRB(16, 12, 16, 80);
  static const cardMargin = EdgeInsets.only(bottom: 14);
  static const cardHeaderPadding = EdgeInsets.fromLTRB(14, 12, 14, 10);
  static const cardBodyPadding = EdgeInsets.fromLTRB(14, 8, 14, 14);
  static const badgePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  static const auditPadding = EdgeInsets.all(12);
  static const stepperPadding = EdgeInsets.symmetric(
    vertical: 8,
    horizontal: 8,
  );
  static const connectorMargin = EdgeInsets.only(bottom: 12);

  static double emptyTopSpacing(BuildContext context) =>
      MediaQuery.sizeOf(context).height * 0.18;

  static const screenTitle = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 15,
  );
  static const reportAction = TextStyle(fontWeight: FontWeight.w700);
  static const selectedFilter = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static const unselectedFilter = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AgrisellColors.headingGreen,
  );
  static const emptyTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.headingGreen,
  );
  static const emptyMessage = TextStyle(
    fontSize: 13,
    color: AgrisellColors.mutedText,
  );
  static const categoryText = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static const mutedText = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
  );
  static const reportId = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.mutedText,
  );
  static const referenceSeparator = TextStyle(color: AgrisellColors.mutedText);
  static const orderReference = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.forestGreen,
  );
  static const statementLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.mutedText,
    letterSpacing: 0.5,
  );
  static const description = TextStyle(
    fontSize: 13,
    color: AgrisellColors.headingGreen,
    height: 1.4,
  );
  static const auditTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.forestGreen,
  );
  static const auditAuthor = TextStyle(
    fontSize: 12,
    color: AgrisellColors.headingGreen,
  );

  static const emptyIcon = BoxDecoration(
    color: AgrisellColors.forestSoft,
    shape: BoxShape.circle,
  );
  static final submitReportButton = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.forestSoft,
    foregroundColor: AgrisellColors.forestGreen,
  );

  static final card = _cardDecoration(emergency: false);
  static final emergencyCard = _cardDecoration(emergency: true);
  static BoxDecoration _cardDecoration({required bool emergency}) =>
      BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: emergency
              ? AgrisellColors.statusRedText.withValues(alpha: 0.4)
              : AgrisellColors.borderLine,
          width: emergency ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static const cardHeader = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
  );
  static final emergencyCardHeader = BoxDecoration(
    color: AgrisellColors.statusRedBackground.withValues(alpha: 0.5),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
  );
  static const category = BoxDecoration(
    color: AgrisellColors.forestGreen,
    borderRadius: BorderRadius.all(Radius.circular(6)),
  );
  static const emergencyCategory = BoxDecoration(
    color: AgrisellColors.statusRedText,
    borderRadius: BorderRadius.all(Radius.circular(6)),
  );
  static final audit = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: AgrisellColors.forestGreen.withValues(alpha: 0.2),
    ),
  );

  // Delegated stepper and status styles
  static BoxDecoration get stepper => IncidentTrackingStatusStyles.stepper;
  static TextStyle get completedStep => IncidentTrackingStatusStyles.completedStep;
  static TextStyle get activeStep => IncidentTrackingStatusStyles.activeStep;
  static TextStyle get rejectedStep => IncidentTrackingStatusStyles.rejectedStep;
  static TextStyle get pendingStep => IncidentTrackingStatusStyles.pendingStep;
  static Color get completedConnector =>
      IncidentTrackingStatusStyles.completedConnector;
  static Color get pendingConnector =>
      IncidentTrackingStatusStyles.pendingConnector;

  static BoxDecoration statusDecoration(SafetyIncidentStatus status) =>
      IncidentTrackingStatusStyles.statusDecoration(status);
  static TextStyle statusText(SafetyIncidentStatus status) =>
      IncidentTrackingStatusStyles.statusText(status);
}
