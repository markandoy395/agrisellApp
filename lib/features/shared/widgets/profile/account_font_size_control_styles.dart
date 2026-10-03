import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/widgets/profile/account_card_style.dart';

abstract final class AccountFontSizeControlStyles {
  static final containerDecoration = BoxDecoration(
    border: Border.all(color: const Color(0xFFE0EAEB)),
    borderRadius: BorderRadius.circular(8),
  );

  static const textStyle = TextStyle(
    color: AccountProfileStyle.ink,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static final containerDecoration2 = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(11),
    border: Border.all(color: AccountProfileStyle.borderSubtle, width: 1),
  );

  static const fontSizeText = TextStyle(
    color: AccountProfileStyle.ink,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );
}
