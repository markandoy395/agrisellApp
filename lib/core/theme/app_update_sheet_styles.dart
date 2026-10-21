import 'package:flutter/material.dart';

import 'agrisell_colors.dart';

abstract final class AppUpdateSheetStyles {
  static const margin = EdgeInsets.all(12);
  static const padding = EdgeInsets.fromLTRB(20, 10, 20, 20);
  static const constraints = BoxConstraints(maxWidth: 560);
  static final borderRadius = BorderRadius.circular(20);
  static const surface = AgrisellColors.surface;
  static const transparent = Colors.transparent;
  static const handleWidth = 38.0;
  static const handleHeight = 4.0;
  static const iconColor = AgrisellColors.authGreen;
  static const iconPadding = EdgeInsets.all(12);
  static const iconDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    shape: BoxShape.circle,
  );
  static final handleDecoration = BoxDecoration(
    color: AgrisellColors.mutedText.withValues(alpha: 0.35),
    borderRadius: BorderRadius.circular(4),
  );
  static const title = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 21,
    fontWeight: FontWeight.w800,
  );
  static const body = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 14,
    height: 1.5,
  );
  static const hint = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
    height: 1.5,
  );
  static const error = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 13,
    height: 1.5,
  );
  static final updateButton = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    minimumSize: const Size.fromHeight(48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  static final laterButton = TextButton.styleFrom(
    foregroundColor: AgrisellColors.headingGreen,
    minimumSize: const Size.fromHeight(48),
  );
}
