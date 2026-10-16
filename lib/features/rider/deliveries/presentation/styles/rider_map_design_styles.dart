import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class RiderMapDesignStyles {
  static const title = AppTypography.title;
  static const body = AppTypography.body;
  static final caption = AppTypography.caption.copyWith(
    color: AgrisellColors.mutedText,
  );
  static final green = AppTypography.subtitle.copyWith(
    color: AgrisellColors.authGreen,
  );
  static final whiteTitle = AppTypography.title.copyWith(
    color: AgrisellColors.surface,
  );
  static final whiteBody = AppTypography.body.copyWith(
    color: AgrisellColors.surface,
  );
  static const header = BoxDecoration(
    gradient: LinearGradient(
      colors: [AgrisellColors.forestSoft, AgrisellColors.surface],
    ),
  );
  static final sheet = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.headingGreen.withValues(alpha: .08),
        blurRadius: 18,
      ),
    ],
  );
  static final card = BoxDecoration(
    color: AgrisellColors.surface,
    border: Border.all(color: AgrisellColors.borderLine),
    borderRadius: BorderRadius.circular(14),
  );
  static const onlinePill = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.all(Radius.circular(24)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.greenGlow,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
  static const offlinePill = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.all(Radius.circular(24)),
    border: Border.fromBorderSide(BorderSide(color: AgrisellColors.borderLine)),
  );
  static final onlineText = AppTypography.subtitle.copyWith(
    color: AgrisellColors.surface,
    fontWeight: FontWeight.w600,
  );
  static const marker = BoxDecoration(
    color: AgrisellColors.authGreen,
    shape: BoxShape.circle,
    border: Border.fromBorderSide(
      BorderSide(color: AgrisellColors.surface, width: 2.5),
    ),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.shadowStrong,
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
  );
  static final riderMarker = marker.copyWith(
    color: AgrisellColors.statusBlueText,
  );
  static BoxDecoration markerFor(IconData icon) {
    if (icon == Icons.navigation_rounded || icon == Icons.navigation) {
      return riderMarker;
    }
    if (icon == Icons.location_on ||
        icon == Icons.location_on_outlined ||
        icon == Icons.location_on_rounded) {
      return marker.copyWith(color: AgrisellColors.statusRedText);
    }
    if (icon == Icons.inventory_2_rounded ||
        icon == Icons.inventory_2_outlined ||
        icon == Icons.local_shipping_rounded) {
      return marker.copyWith(color: AgrisellColors.statusOrangeText);
    }
    if (icon == Icons.local_hospital_rounded ||
        icon == Icons.local_hospital_outlined) {
      return marker.copyWith(color: AgrisellColors.statusRedText);
    }
    if (icon == Icons.storefront_rounded ||
        icon == Icons.storefront_outlined ||
        icon == Icons.local_gas_station_rounded ||
        icon == Icons.local_gas_station_outlined) {
      return marker.copyWith(color: AgrisellColors.statusBlueText);
    }
    if (icon == Icons.park_rounded || icon == Icons.park_outlined) {
      return marker.copyWith(color: AgrisellColors.authGreen);
    }
    return marker;
  }

  static const markerCallout = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.all(Radius.circular(6)),
    border: Border.fromBorderSide(BorderSide(color: AgrisellColors.borderLine)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.shadowMedium,
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ],
  );
  static const markerCalloutText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.brandBlack,
  );
  static final control = IconButton.styleFrom(
    backgroundColor: AgrisellColors.surface,
    foregroundColor: AgrisellColors.headingGreen,
    minimumSize: const Size(44, 44),
    elevation: 3,
    shadowColor: AgrisellColors.shadowButton,
    shape: const CircleBorder(),
  );
  static final status = OutlinedButton.styleFrom(
    backgroundColor: AgrisellColors.surface,
    foregroundColor: AgrisellColors.authGreen,
    maximumSize: Size.infinite,
    minimumSize: const Size(0, 44),
    textStyle: AppTypography.button,
    side: const BorderSide(color: AgrisellColors.borderLine),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
  static BoxDecoration viewChoice(bool selected) => BoxDecoration(
    color: AgrisellColors.surface,
    border: Border.all(
      color: selected ? AgrisellColors.authGreen : AgrisellColors.borderLine,
      width: selected ? 2.2 : 1,
    ),
    borderRadius: BorderRadius.circular(12),
    boxShadow: selected
        ? const [
            BoxShadow(
              color: AgrisellColors.greenGlowSoft,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ]
        : null,
  );
  static final primaryButton = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    minimumSize: const Size(0, 44),
    maximumSize: Size.infinite,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
  );
  static const carouselIconContainer = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );
  static const carouselCard = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(BorderSide(color: AgrisellColors.borderLine)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.shadowLight,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
  static const priceGreen = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AgrisellColors.authGreen,
  );
  static const metaText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 11,
    color: AgrisellColors.mutedText,
  );
}
