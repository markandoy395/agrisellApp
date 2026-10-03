import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined style constants for the rider history screen.
abstract final class RiderHistoryStyles {
  // Padding & Insets
  static const EdgeInsets listPadding = EdgeInsets.all(14);

  // Spacing
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;

  // Search Input Decoration
  static final InputDecoration searchInputDecoration = InputDecoration(
    hintText: 'Search order, product, participant, location, or payment',
    prefixIcon: const Icon(Icons.search_rounded),
    filled: true,
    fillColor: AgrisellColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  // Filter Buttons
  static const double dateFilterIconSize = 18.0;
}
