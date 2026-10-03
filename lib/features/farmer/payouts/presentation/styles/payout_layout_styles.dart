import 'package:flutter/material.dart';

abstract final class PayoutLayoutStyles {
  static const cashOutIconSize = 18.0;
  static const actionIconSize = 16.0;
  static const fullWidth = double.infinity;

  static double emptyStateTopSpace(BuildContext context) =>
      MediaQuery.sizeOf(context).height * 0.18;

  static const metricsPadding = EdgeInsets.fromLTRB(16, 14, 16, 16);

  static const metricPadding = EdgeInsets.all(12);

  static const sectionGap = 12.0;

  static const detailSectionGap = 18.0;

  static const detailHeaderGap = 16.0;

  static const labelGap = 6.0;

  static const tinyGap = 2.0;

  static const alignStart = CrossAxisAlignment.start;

  static const spaceBetween = MainAxisAlignment.spaceBetween;

  static const listPadding = EdgeInsets.fromLTRB(16, 16, 16, 32);

  static const emptyIconSize = 60.0;

  static const emptyIconGlyphSize = 30.0;

  static const smallGap = 4.0;

  static const shrinkWrap = MainAxisSize.min;

  static const cashOutTagPadding = EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 2,
  );

  static const inlineGap = 8.0;

  static const contentGap = 10.0;

  static const referencePadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );

  static const copyIconPadding = EdgeInsets.all(2);

  static const copyIconSize = 14.0;

  static const detailPadding = EdgeInsets.fromLTRB(20, 16, 20, 24);

  static const summaryLinePadding = EdgeInsets.only(bottom: 8);

  static const dragHandleWidth = 36.0;

  static const closeIconSize = 20.0;

  static const summaryLabelWidth = 140.0;

  static const cardPadding = EdgeInsets.all(14);

  static const flatElevation = 0.0;

  static const tabIndicatorWeight = 3.0;

  static const alignEnd = CrossAxisAlignment.end;

  static const statusBadgePadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 3,
  );
}
