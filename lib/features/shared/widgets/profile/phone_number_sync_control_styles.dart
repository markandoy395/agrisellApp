import 'package:flutter/material.dart';

abstract final class PhoneNumberSyncControlStyles {
  static final containerDecoration = BoxDecoration(
    color: const Color(0xFFEDF8F0),
    borderRadius: BorderRadius.circular(12),
  );

  static const syncContactToPhoneText = TextStyle(
    color: Color(0xFF075239),
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const easilyFindAndConnectWithText = TextStyle(
    fontSize: 11,
    color: Colors.blueGrey,
  );

  static final _syncContactToPhoneText2Active = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static final _syncContactToPhoneText2Inactive = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static TextStyle syncContactToPhoneText2(bool spacious) => spacious
      ? _syncContactToPhoneText2Active
      : _syncContactToPhoneText2Inactive;
}
