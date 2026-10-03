import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class PayoutSurfaceStyles {
  static const white = Colors.white;
  static const transparent = Colors.transparent;
  static const rejectedText = Color(0xFFE02424);
  static const failedBackground = Color(0xFFFDE8E8);

  static Color payoutStatusColor(bool isPaid) =>
      isPaid ? AgrisellColors.statusGreenText : AgrisellColors.statusOrangeText;

  static Color cashOutStatusColor(bool isPaid, bool isRejected) => isPaid
      ? AgrisellColors.statusGreenText
      : (isRejected ? rejectedText : AgrisellColors.statusOrangeText);

  static Color cardStatusBackground(bool isPaid, bool hasFailed) => isPaid
      ? AgrisellColors.statusGreenBackground
      : (hasFailed ? failedBackground : AgrisellColors.statusOrangeBackground);

  static Color detailBackground(bool isPaid) => isPaid
      ? AgrisellColors.statusGreenBackground
      : AgrisellColors.statusOrangeBackground;

  static final cashOutButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 0,
  );

  static BoxDecoration amountPanel(Color backgroundColor) => BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(12),
  );

  static const emptyIcon = BoxDecoration(
    color: AgrisellColors.searchBackground,
    shape: BoxShape.circle,
  );

  static const detailSheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );

  static final cashOutTag = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: BorderRadius.circular(5),
  );

  static final reference = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: BorderRadius.circular(6),
  );

  static final dragHandle = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.circular(2),
  );

  static final payoutCard = _historyCard();
  static final cashOutCard = _historyCard(
    border: Border.all(color: AgrisellColors.authGreen.withValues(alpha: 0.2)),
  );

  static BoxDecoration historyCard(bool isCashOut) =>
      isCashOut ? cashOutCard : payoutCard;

  static BoxDecoration _historyCard({Border? border}) => BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: border,
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static final cardRadius = BorderRadius.circular(14);

  static BoxDecoration statusBadge(Color backgroundColor) => BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(6),
  );
}
