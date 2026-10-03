import 'package:flutter/material.dart';

abstract final class BuyerProfileContentStyles {
  static final containerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static final containerDecoration2 = BoxDecoration(
    color: const Color(0xFFE8F5E9),
    borderRadius: BorderRadius.circular(10),
  );

  static const browseAvailableVouchersAndDiscountsText = TextStyle(
    fontSize: 12,
    color: Colors.black54,
  );
}
