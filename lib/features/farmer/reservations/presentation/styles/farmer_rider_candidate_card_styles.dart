import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';

abstract final class FarmerRiderCandidateCardStyles {
  // Card Container
  static final cardDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static const cardPadding = EdgeInsets.all(12);

  // Identity Section
  static const nameStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );
  static const locationStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const localityHighlightStyle = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static const gpsWarningStyle = TextStyle(
    color: AgrisellColors.statusOrangeText,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static const localityPadding = EdgeInsets.only(top: 4);

  // Avatar
  static const avatarRadius = 24.0;
  static const avatarBackground = AgrisellColors.forestSoft;
  static const avatarFallbackStyle = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  // Availability Badge
  static const badgePadding = EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 4,
  );
  static final badgeRadius = BorderRadius.circular(20);

  static BoxDecoration badgeDecoration(bool online) => BoxDecoration(
    color: online
        ? AgrisellColors.statusGreenBackground
        : AgrisellColors.statusOrangeBackground,
    borderRadius: badgeRadius,
  );

  static TextStyle badgeTextStyle(bool online) => TextStyle(
    color: online
        ? AgrisellColors.statusGreenText
        : AgrisellColors.statusOrangeText,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static String availabilityLabel(String status) => switch (status) {
    'busy' => 'Busy',
    'online' => 'Online',
    _ => 'Offline',
  };

  // Metrics
  static const metricsWrapSpacing = 12.0;
  static const metricsWrapRunSpacing = 6.0;
  static const metricIconSize = 15.0;
  static const metricIconColor = AgrisellColors.authGreen;
  static const metricLabelStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static String pickupDistanceLabel(double? distanceKm) {
    if (distanceKm == null) return 'Distance unavailable';
    return '${distanceKm.toStringAsFixed(1)} km from pickup';
  }

  // Button
  static const buttonHeight = 38.0;
  static final buttonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
    ),
  );

  static String actionButtonLabel(FarmerRiderCandidate rider) {
    if (rider.canReceiveRequest) {
      return rider.isOfflineManualCandidate
          ? 'Book offline rider'
          : 'Select rider';
    }
    if (rider.availabilityStatus == 'online') {
      return 'Rider is not eligible';
    }
    return 'Rider is ${availabilityLabel(rider.availabilityStatus)}';
  }
}
