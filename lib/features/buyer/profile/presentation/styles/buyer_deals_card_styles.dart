import 'package:flutter/material.dart';

abstract final class BuyerDealsCardStyles {
  static final containerDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF0B5435), Color(0xFF0E7A4F), Color(0xFF1AA06A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.55, 1.0],
    ),
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF08683F).withValues(alpha: 0.35),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static final containerDecoration2 = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
  );

  static const voucherWalletDealsText = TextStyle(
    fontFamily: 'Poppins',
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static final containerDecoration3 = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.15),
    shape: BoxShape.circle,
  );
}
