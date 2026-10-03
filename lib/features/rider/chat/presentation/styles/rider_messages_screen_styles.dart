import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderMessagesScreenStyles {
  static final inputDecoration = InputDecoration(
    hintText: 'Search delivery messages',
    prefixIcon: const Icon(Icons.search_rounded),
    filled: true,
    fillColor: AgrisellColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}
