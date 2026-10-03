import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/rider_assignment_request_status.dart';

class FarmerRiderRequestPresentation {
  const FarmerRiderRequestPresentation(this.icon, this.color, this.background);

  final IconData icon;
  final Color color;
  final Color background;
}

abstract final class FarmerRiderRequestStyles {
  static const borderRadiusValue = 10.0;
  static const padding = EdgeInsets.all(10);
  static const actionButtonHeight = 36.0;

  static BoxDecoration boxDecoration(
    FarmerRiderRequestPresentation presentation,
  ) => BoxDecoration(
    color: presentation.background,
    borderRadius: BorderRadius.circular(borderRadiusValue),
    border: Border.all(color: presentation.color.withValues(alpha: 0.3)),
  );

  static TextStyle statusTextStyle(Color color) => TextStyle(
    color: color,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const messageTextStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  static final chooseAnotherButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
  );

  static FarmerRiderRequestPresentation presentationFor(
    RiderAssignmentRequestStatus status,
  ) => switch (status) {
    RiderAssignmentRequestStatus.pending => const FarmerRiderRequestPresentation(
      Icons.schedule_rounded,
      AgrisellColors.statusOrangeText,
      AgrisellColors.statusOrangeBackground,
    ),
    RiderAssignmentRequestStatus.accepted => const FarmerRiderRequestPresentation(
      Icons.check_circle_outline_rounded,
      AgrisellColors.statusGreenText,
      AgrisellColors.statusGreenBackground,
    ),
    RiderAssignmentRequestStatus.declined ||
    RiderAssignmentRequestStatus.failed => const FarmerRiderRequestPresentation(
      Icons.error_outline_rounded,
      AgrisellColors.statusRedText,
      AgrisellColors.statusRedBackground,
    ),
    RiderAssignmentRequestStatus.expired ||
    RiderAssignmentRequestStatus.cancelled => const FarmerRiderRequestPresentation(
      Icons.timer_off_outlined,
      AgrisellColors.statusPurpleText,
      AgrisellColors.statusPurpleBackground,
    ),
  };
}
