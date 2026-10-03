import 'package:flutter/material.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';

abstract final class OrdersCardStyles {
  static const viewAllText = TextStyle(
    color: BuyerProfileStyle.green,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static final containerDecoration = BoxDecoration(
    color: const Color(0xFFF7F4FA),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFF9C27B0).withValues(alpha: 0.15)),
  );

  static const refundsReturnsTrackStatusText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF7B1FA2),
  );
}
