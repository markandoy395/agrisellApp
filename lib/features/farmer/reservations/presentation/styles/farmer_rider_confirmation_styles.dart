import 'package:flutter/material.dart';

abstract final class FarmerRiderConfirmationStyles {
  // Theme colors
  static const green = Color(0xFF116F43);
  static const mint = Color(0xFFE8F6EF);
  static const ink = Color(0xFF10252C);
  static const muted = Color(0xFF6B7A80);
  static const barrierColor = Color(0x4D123D2E);
  static const dividerColor = Color(0xFFE6ECE9);
  static const feeBackground = Color(0xFFF5F8F6);
  static const feeBorder = Color(0xFFE4ECE7);
  static const offlineWarningBackground = Color(0xFFFFF6E7);
  static const offlineWarningIconColor = Color(0xFF997025);
  static const offlineWarningTextColor = Color(0xFF805F27);

  // Dialog Layout
  static final dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  );
  static const dialogInsetPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 24,
  );
  static const dialogConstraints = BoxConstraints(maxWidth: 460);
  static const dialogTitlePadding = EdgeInsets.fromLTRB(22, 22, 12, 0);
  static const dialogContentPadding = EdgeInsets.fromLTRB(22, 16, 22, 12);
  static const dialogActionsPadding = EdgeInsets.fromLTRB(22, 6, 22, 22);

  // Header
  static const headerIconBoxSize = 46.0;
  static final headerIconBoxDecoration = BoxDecoration(
    color: mint,
    borderRadius: BorderRadius.circular(14),
  );
  static const titleStyle = TextStyle(
    color: ink,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const subtitleStyle = TextStyle(
    color: muted,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  // Rider Card
  static const riderCardPadding = EdgeInsets.all(14);
  static final riderCardDecoration = BoxDecoration(
    color: mint,
    borderRadius: BorderRadius.circular(14),
  );
  static const riderHeadingStyle = TextStyle(
    color: green,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  static const riderNameStyle = TextStyle(
    color: ink,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  // Details
  static const detailPadding = EdgeInsets.only(bottom: 12);
  static const distancePadding = EdgeInsets.only(left: 34, bottom: 12);
  static const detailLabelStyle = TextStyle(color: muted, fontSize: 12);
  static const detailValueStyle = TextStyle(
    color: ink,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static const distanceTextStyle = TextStyle(
    color: green,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Fee Card
  static const feeContainerPadding = EdgeInsets.all(14);
  static final feeContainerDecoration = BoxDecoration(
    color: feeBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: feeBorder),
  );
  static const feeLabelStyle = TextStyle(color: muted, fontSize: 12);
  static const feeValueStyle = TextStyle(
    color: green,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  // Note Card
  static const notePadding = EdgeInsets.all(12);
  static BoxDecoration noteDecoration(bool isOffline) => BoxDecoration(
    color: isOffline ? offlineWarningBackground : mint,
    borderRadius: BorderRadius.circular(12),
  );
  static TextStyle noteTextStyle(bool isOffline) => TextStyle(
    color: isOffline ? offlineWarningTextColor : green,
    fontSize: 12,
    height: 1.45,
  );
  static Color noteIconColor(bool isOffline) =>
      isOffline ? offlineWarningIconColor : green;

  // Buttons
  static const buttonTextStyle = TextStyle(fontWeight: FontWeight.w600);
  static final backButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: green,
    minimumSize: const Size(double.infinity, 48),
    maximumSize: Size.infinite,
    side: const BorderSide(color: green),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  static final sendButtonStyle = FilledButton.styleFrom(
    backgroundColor: green,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 48),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
