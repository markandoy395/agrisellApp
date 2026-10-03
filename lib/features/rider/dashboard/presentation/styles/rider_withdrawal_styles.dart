import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderWithdrawalStyles {
  static const alignStart = CrossAxisAlignment.start;
  static const shrinkWrap = MainAxisSize.min;
  static const spaceBetween = MainAxisAlignment.spaceBetween;
  static const centeredRow = MainAxisAlignment.center;
  static const centeredText = TextAlign.center;
  static const fullWidth = double.infinity;
  static const tinyGap = 2.0;
  static const labelGap = 6.0;
  static const inlineGap = 8.0;
  static const itemGap = 10.0;
  static const controlGap = 12.0;
  static const fieldGap = 14.0;
  static const sectionGap = 16.0;
  static const dragHandleWidth = 36.0;
  static const dragHandleHeight = 4.0;
  static const actionIconSize = 20.0;
  static const typeIconSize = 18.0;
  static const spinnerSize = 20.0;
  static const spinnerStrokeWidth = 2.0;
  static const spinnerColor = Colors.white;
  static const deleteColor = Colors.red;
  static const sheetPadding = EdgeInsets.fromLTRB(20, 16, 20, 24);
  static const emptyPadding = EdgeInsets.all(20);
  static const tilePadding = EdgeInsets.all(14);
  static const iconPadding = EdgeInsets.all(10);
  static const typePadding = EdgeInsets.symmetric(vertical: 10, horizontal: 12);
  static const defaultPadding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 2,
  );
  static const switchPadding = EdgeInsets.zero;

  static EdgeInsets keyboardPadding(BuildContext context) =>
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom);

  static final dragHandle = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.circular(2),
  );
  static final emptyPanel = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: BorderRadius.circular(12),
  );
  static final defaultBadge = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: BorderRadius.circular(4),
  );
  static const title = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.headingGreen,
  );
  static const subtitle = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
  );
  static const accountDetails = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    fontWeight: FontWeight.w600,
  );
  static const fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );
  static const methodLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.brandBlack,
  );
  static const defaultLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AgrisellColors.authGreen,
  );
  static const saveLabel = TextStyle(fontWeight: FontWeight.w700);
}
