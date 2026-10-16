import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';
import 'rider_delivery_reference_styles.dart';

abstract final class RiderPickupDesignStyles {
  static const background = AgrisellColors.pageBackground;
  static const radius = BorderRadius.all(Radius.circular(14));
  static const header = RiderDeliveryReferenceStyles.header;
  static final heading = RiderDeliveryReferenceStyles.heading;
  static final title = RiderDeliveryReferenceStyles.title;
  static final body = RiderDeliveryReferenceStyles.body;
  static final caption = RiderDeliveryReferenceStyles.caption;
  static final pickupLabel = body.copyWith(fontWeight: FontWeight.w600);
  static final whiteCaption = RiderDeliveryReferenceStyles.whiteCaption;
  static final error = AppTypography.caption.copyWith(
    color: AgrisellColors.statusRedText,
  );
  static final timer = AppTypography.title.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.statusRedText,
  );
  static TextStyle gps(bool ready) => AppTypography.title.copyWith(
    fontWeight: FontWeight.w600,
    color: ready ? AgrisellColors.authGreen : AgrisellColors.statusRedText,
  );
  static BoxDecoration tint(Color color) =>
      RiderDeliveryReferenceStyles.tint(color);
  static final primary = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    minimumSize: const Size(0, 50),
    maximumSize: Size.infinite,
    shape: const RoundedRectangleBorder(borderRadius: radius),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
  );
  static final secondary = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.statusRedText,
    minimumSize: const Size(0, 50),
    maximumSize: Size.infinite,
    side: const BorderSide(color: AgrisellColors.statusRedText),
    shape: const RoundedRectangleBorder(borderRadius: radius),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    textStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
  );
  static final cancel = secondary.copyWith(
    foregroundColor: const WidgetStatePropertyAll(AgrisellColors.headingGreen),
    side: const WidgetStatePropertyAll(
      BorderSide(color: AgrisellColors.mutedText),
    ),
  );
  static ButtonStyle proof(bool saved) => OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    backgroundColor: saved ? AgrisellColors.forestSoft : AgrisellColors.surface,
    minimumSize: const Size(0, 100),
    maximumSize: Size.infinite,
    side: const BorderSide(color: AgrisellColors.borderLine),
    shape: const RoundedRectangleBorder(borderRadius: radius),
    textStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w500),
    padding: const EdgeInsets.all(12),
  );
  static InputDecoration input(
    String label, {
    IconData? icon,
    Widget? suffix,
    String? hint,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    labelStyle: caption,
    hintStyle: caption,
    prefixIcon: icon == null
        ? null
        : Icon(icon, color: AgrisellColors.headingGreen, size: 22),
    suffixIcon: suffix,
    filled: true,
    fillColor: AgrisellColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: AgrisellColors.borderLine),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: AgrisellColors.borderLine),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: AgrisellColors.authGreen),
    ),
  );
}
