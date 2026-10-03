import 'package:flutter/material.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';

abstract final class OrderStatusItemStyles {
  static final containerDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(13),
    border: Border.all(color: BuyerProfileStyle.borderSubtle, width: 1),
  );

  static const labelText = TextStyle(
    fontFamily: 'Poppins',
    color: BuyerProfileStyle.ink,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
