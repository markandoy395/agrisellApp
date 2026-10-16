import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';
import '../../domain/rider_map_visibility.dart';
import 'rider_live_map_styles.dart';

abstract final class RiderMapViewStyles {
  static const title = AppTypography.title;
  static final label = AppTypography.caption.copyWith(
    color: AgrisellColors.headingGreen,
    fontWeight: FontWeight.w600,
  );
  static const thumbnailRadius = BorderRadius.all(Radius.circular(8));
  static const cardRadius = BorderRadius.all(Radius.circular(12));
  static BoxDecoration card(bool selected) => BoxDecoration(
    color: selected ? AgrisellColors.surface : AgrisellColors.pageBackground,
    border: Border.all(
      color: selected ? AgrisellColors.authGreen : AgrisellColors.borderLine,
      width: 2,
    ),
    borderRadius: cardRadius,
  );

  // Fixed public sample tiles: opening options never requests the rider's GPS.
  static String previewUrl(RiderMapViewType type) {
    final template = switch (type) {
      RiderMapViewType.defaultView => RiderLiveMapStyles.osmTileUrl,
      RiderMapViewType.satellite => RiderLiveMapStyles.satelliteTileUrl,
      RiderMapViewType.terrain => RiderLiveMapStyles.terrainTileUrl,
    };
    return template
        .replaceAll('{z}', '14')
        .replaceAll('{x}', '13865')
        .replaceAll('{y}', '7804');
  }

  static Color land(RiderMapViewType type) => switch (type) {
    RiderMapViewType.defaultView => AgrisellColors.pageBackground,
    RiderMapViewType.satellite => AgrisellColors.forestDark,
    RiderMapViewType.terrain => AgrisellColors.deliveryGray,
  };
  static Paint road(RiderMapViewType type, double width) => Paint()
    ..color = type == RiderMapViewType.satellite
        ? AgrisellColors.accentOrange.withValues(alpha: .7)
        : AgrisellColors.surface
    ..strokeWidth = width
    ..style = PaintingStyle.stroke;
  static Paint field(int index) => Paint()
    ..color = [
      AgrisellColors.forestGreen,
      AgrisellColors.forestDark,
      AgrisellColors.deliveryGreen,
      AgrisellColors.headingGreen,
    ][index % 4];
  static final park = Paint()..color = AgrisellColors.forestSoft;
  static final water = Paint()..color = AgrisellColors.accentBlue;
  static final contour = Paint()
    ..color = AgrisellColors.mutedText.withValues(alpha: .5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
}
