import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';

abstract final class RiderMapMarkerSheetStyles {
  // Colors
  static const Color surfaceColor = AgrisellColors.surface;
  static const Color chipBackground = AgrisellColors.homeBackground;
  static const Color chipIconColor = AgrisellColors.authGreen;
  static const Color farmAvatarBg = AgrisellColors.forestSoft;
  static const Color farmAvatarFg = AgrisellColors.headingGreen;

  // Text Styles
  static const TextStyle titleTextStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle subtitleTextStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const TextStyle chipTextStyle = TextStyle(
    fontSize: 12,
  );

  static const TextStyle detailLabelTextStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle detailValueTextStyle = TextStyle(
    fontSize: 12,
    height: 1.35,
  );

  static const TextStyle priorityWarningTextStyle = TextStyle(
    color: AgrisellColors.statusOrangeText,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  // Spacing & Insets
  static const EdgeInsets sheetPadding = EdgeInsets.fromLTRB(20, 0, 20, 20);
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 7,
  );
  static const EdgeInsets detailRowPadding = EdgeInsets.only(top: 8);

  static const double chipSpacing = 8.0;
  static const double chipRunSpacing = 8.0;
  static const double detailLabelWidth = 58.0;

  // Decorations
  static final BoxDecoration chipDecoration = BoxDecoration(
    color: chipBackground,
    borderRadius: BorderRadius.circular(18),
  );

  // Marker Presentation Helpers
  static Color markerColor(RiderMapMarkerKind kind) => switch (kind) {
    RiderMapMarkerKind.availableDelivery => AgrisellColors.statusBlueText,
    RiderMapMarkerKind.farmer => AgrisellColors.headingGreen,
    RiderMapMarkerKind.assignedDelivery => AgrisellColors.statusOrangeText,
  };

  static Color markerAvatarBg(RiderMapMarkerKind kind) =>
      markerColor(kind).withValues(alpha: 0.14);

  static IconData markerIcon(RiderMapMarkerKind kind) => switch (kind) {
    RiderMapMarkerKind.availableDelivery => Icons.inventory_2_rounded,
    RiderMapMarkerKind.farmer => Icons.agriculture_rounded,
    RiderMapMarkerKind.assignedDelivery => Icons.local_shipping_rounded,
  };
}
