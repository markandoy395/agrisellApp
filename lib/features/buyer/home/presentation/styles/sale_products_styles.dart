import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class SaleProductsStyles {
  static const searchFieldPadding = EdgeInsets.fromLTRB(16, 16, 16, 10);
  static const countLabelPadding = EdgeInsets.fromLTRB(18, 0, 18, 12);
  static const gridPadding = EdgeInsets.symmetric(horizontal: 12);
  static const emptyPadding = EdgeInsets.all(28);
  static const bottomSpacer = SizedBox(height: 28);

  static const appBarTitleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const countLabelStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const emptyMessageStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
  );

  static final searchDecoration = InputDecoration(
    hintText: 'Search sale products',
    prefixIcon: const Icon(Icons.search_rounded),
    filled: true,
    fillColor: AgrisellColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
  );
}
