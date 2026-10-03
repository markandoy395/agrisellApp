import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/presentation/rider_availability_presentation.dart';

abstract final class RiderAvailabilityCardStyles {
  // Card
  static const cardPadding = EdgeInsets.all(16);

  // Shift Icon
  static const iconBoxSize = 48.0;
  static const iconSize = 25.0;
  static final iconRadius = BorderRadius.circular(14);

  static Color iconColor(RiderAvailability availability) =>
      availability.canReceiveRequests
          ? AgrisellColors.statusGreenText
          : availability.isHandlingDelivery
          ? AgrisellColors.statusBlueText
          : AgrisellColors.mutedText;

  static Color iconBackground(RiderAvailability availability) =>
      availability.canReceiveRequests
          ? AgrisellColors.statusGreenBackground
          : availability.isHandlingDelivery
          ? AgrisellColors.statusBlueBackground
          : AgrisellColors.deliveryGray.withValues(alpha: 0.75);

  static BoxDecoration iconBoxDecoration(RiderAvailability availability) =>
      BoxDecoration(
        color: iconBackground(availability),
        borderRadius: iconRadius,
      );

  // Shift Copy
  static const workStatusTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    height: 1.1,
    fontWeight: FontWeight.w900,
  );

  static const workStatusSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  static String availabilityLabel(RiderAvailability availability) =>
      switch (availability) {
        RiderAvailability.onlineAvailable => 'Online',
        RiderAvailability.reviewingDeliveryRequest => 'Reviewing',
        RiderAvailability.deliveryReserved => 'Reserved',
        RiderAvailability.goingToPickup => 'To pickup',
        RiderAvailability.waitingAtPickup => 'At pickup',
        RiderAvailability.productPickedUp => 'Picked up',
        RiderAvailability.goingToBuyer => 'To buyer',
        RiderAvailability.waitingAtDeliveryLocation => 'At drop-off',
        RiderAvailability.temporarilyUnavailable => 'Unavailable',
        _ => availability.displayLabel,
      };

  static String gpsLabel(RiderGpsStatus status) => switch (status) {
    RiderGpsStatus.checking => 'GPS checking',
    RiderGpsStatus.ready => 'GPS ready',
    RiderGpsStatus.disabled => 'GPS off',
    RiderGpsStatus.permissionDenied => 'GPS denied',
    RiderGpsStatus.permissionDeniedForever => 'GPS blocked',
    RiderGpsStatus.approximateLocation => 'Approximate GPS',
    RiderGpsStatus.poorAccuracy => 'Weak GPS',
    RiderGpsStatus.timedOut => 'GPS timeout',
    RiderGpsStatus.unavailable => 'GPS unavailable',
  };

  static String internetLabel(RiderInternetStatus status) => switch (status) {
    RiderInternetStatus.unknown => 'Checking',
    RiderInternetStatus.checking => 'Checking',
    RiderInternetStatus.online => 'Connected',
    RiderInternetStatus.offline => 'Offline',
    RiderInternetStatus.reconnecting => 'Reconnecting',
    RiderInternetStatus.backendUnavailable => 'Backend down',
  };

  static String statusSummary({
    required RiderAvailability availability,
    required RiderGpsStatus gpsStatus,
    required RiderInternetStatus internetStatus,
  }) =>
      '${availabilityLabel(availability)} - '
      '${gpsLabel(gpsStatus)} - '
      '${internetLabel(internetStatus)}';

  // Switch
  static const activeThumbColor = AgrisellColors.authGreen;
  static const activeTrackColor = AgrisellColors.forestSoft;

  // Notice & Warning
  static const noticePadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 8,
  );
  static const warningPadding = EdgeInsets.fromLTRB(10, 8, 4, 8);
  static final alertDecoration = BoxDecoration(
    color: AgrisellColors.statusOrangeBackground,
    borderRadius: BorderRadius.circular(10),
  );

  static const noticeTextStyle = TextStyle(
    color: AgrisellColors.statusOrangeText,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );

  static const warningTextStyle = TextStyle(
    color: AgrisellColors.statusOrangeText,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w700,
  );
}
