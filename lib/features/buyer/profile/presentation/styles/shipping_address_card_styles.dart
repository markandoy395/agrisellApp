import 'package:flutter/material.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';

abstract final class ShippingAddressCardStyles {
  static final containerDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: BuyerProfileStyle.borderSubtle, width: 1),
  );

  static final textButtonStyle = TextButton.styleFrom(
    foregroundColor: BuyerProfileStyle.green,
    padding: const EdgeInsets.symmetric(horizontal: 4),
  );

  static const editAddressText = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: BuyerProfileStyle.green,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 38),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
  );

  static const setShippingAddressText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
}
