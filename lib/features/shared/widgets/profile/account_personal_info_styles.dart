import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/widgets/profile/account_card_style.dart';

abstract final class AccountPersonalInfoStyles {
  static const iconContainerSize = 42.0;
  static const iconSize = 24.0;
  static const editIconSize = 18.0;

  static const headerPadding = EdgeInsets.fromLTRB(16, 14, 16, 14);
  static const contentPadding = EdgeInsets.fromLTRB(18, 12, 18, 16);
  static const entryPadding = EdgeInsets.symmetric(vertical: 10);
  static const toggleButtonPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const editButtonPadding = EdgeInsets.symmetric(horizontal: 4);

  static const dividerLight = Color(0xFFEFF3F4);
  static const dividerMedium = Color(0xFFE1E7E9);
  static const dividerItem = Color(0xFFEDF0F2);
  static const activeToggleBackground = Color(0xFFE2EFEA);

  static final headerIconDecoration = BoxDecoration(
    color: AccountProfileStyle.mint,
    borderRadius: BorderRadius.circular(11),
  );

  static const headerTitleStyle = TextStyle(
    color: AccountProfileStyle.ink,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static ButtonStyle toggleButtonStyle(bool isExpanded) => FilledButton.styleFrom(
    backgroundColor:
        isExpanded ? activeToggleBackground : AccountProfileStyle.mint,
    foregroundColor: AccountProfileStyle.green,
    minimumSize: const Size(0, 36),
    padding: toggleButtonPadding,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static const toggleButtonTextStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
  );

  static const sectionTitleStyle = TextStyle(
    color: AccountProfileStyle.muted,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static final editButtonStyle = TextButton.styleFrom(
    foregroundColor: AccountProfileStyle.green,
    padding: editButtonPadding,
  );

  static const editButtonTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
  );

  static const entryLabelStyle = TextStyle(
    color: AccountProfileStyle.muted,
    fontSize: 13,
  );

  static const entryValueStyle = TextStyle(
    color: AccountProfileStyle.ink,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}
