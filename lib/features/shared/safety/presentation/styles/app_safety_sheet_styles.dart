import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class AppSafetySheetStyles {
  static const sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );

  static const sheetPadding = EdgeInsets.fromLTRB(18, 0, 18, 20);

  static const headerIconColor = AgrisellColors.authGreen;
  static const headerIconSize = 24.0;

  static const headerTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const headerSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
  );

  static const sosBorderRadius = BorderRadius.all(Radius.circular(14));

  static final sosContainerDecoration = BoxDecoration(
    color: AgrisellColors.statusRedBackground,
    borderRadius: sosBorderRadius,
    border: Border.all(
      color: AgrisellColors.statusRedText.withValues(alpha: 0.3),
    ),
  );

  static const sosIconDecoration = BoxDecoration(
    color: AgrisellColors.statusRedText,
    shape: BoxShape.circle,
  );

  static const sosIconPadding = EdgeInsets.all(8);
  static const sosIconColor = Colors.white;
  static const sosIconSize = 24.0;

  static const sosTitleStyle = TextStyle(
    color: AgrisellColors.statusRedText,
    fontWeight: FontWeight.w800,
    fontSize: 15,
  );

  static const sosSubtitleStyle = TextStyle(fontSize: 12);

  static final tileShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );

  static const tileBackground = AgrisellColors.pageBackground;

  static const tileTitleStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
  );

  static const reportIconColor = AgrisellColors.headingGreen;
  static const historyIconColor = AgrisellColors.forestGreen;
  static const supportIconColor = AgrisellColors.accentBlue;

  static const sosWarningColor = AgrisellColors.statusRedText;

  static final sosConfirmButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.statusRedText,
  );

  static const dialogFieldLabelStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 13,
  );

  static const dropdownItemStyle = TextStyle(fontSize: 13);

  static const dropdownDecoration = InputDecoration(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  static const reportInputDecoration = InputDecoration(
    hintText:
        'Provide details on what happened, where, and any immediate actions needed…',
    border: OutlineInputBorder(),
  );

  static final submitReportButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
  );

  static const spacingTitleIcon = SizedBox(width: 8);
  static const spacingTitleSubtitle = SizedBox(height: 4);
  static const spacingHeaderBottom = SizedBox(height: 16);
  static const spacingSosBottom = SizedBox(height: 12);
  static const spacingTiles = SizedBox(height: 8);
  static const spacingDialogFields = SizedBox(height: 6);
  static const spacingDialogSections = SizedBox(height: 14);
}
