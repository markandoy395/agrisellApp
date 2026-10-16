import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerDiscountDialogStyles {
  static const transparent = Colors.transparent;
  static const white = Colors.white;
  static const authGreen = AgrisellColors.authGreen;
  static const mutedText = AgrisellColors.mutedText;

  static BoxConstraints sheetConstraints(BuildContext context) =>
      BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88);

  static InputDecoration inputDecoration({
    required String hintText,
    String? prefixText,
    String? suffixText,
  }) => InputDecoration(
    hintText: hintText,
    prefixText: prefixText,
    suffixText: suffixText,
    filled: true,
    fillColor: AgrisellColors.homeBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: inputBorder,
    enabledBorder: inputBorder,
    focusedBorder: focusedInputBorder,
  );

  static final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: AgrisellColors.borderLine),
  );
  static final focusedInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: AgrisellColors.authGreen, width: 1.5),
  );

  static const title = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );

  static const helper = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
  );

  static const dateLabel = TextStyle(fontSize: 12);

  static const error = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const saveLabel = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);

  static const selectAll = TextStyle(
    fontSize: 12,
    color: AgrisellColors.authGreen,
    fontWeight: FontWeight.w700,
  );

  static const productName = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const preview = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.authGreen,
  );

  static const sheet = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  );

  static final dragHandle = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.circular(2),
  );

  static final offerIcon = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(8),
  );

  static final products = BoxDecoration(
    color: AgrisellColors.homeBackground,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const headerPadding = EdgeInsets.fromLTRB(20, 14, 20, 10);

  static const offerIconPadding = EdgeInsets.all(6);

  static const bodyPadding = EdgeInsets.fromLTRB(20, 16, 20, 24);

  static const footerPadding = EdgeInsets.fromLTRB(20, 12, 20, 24);

  static EdgeInsets keyboardPadding(BuildContext context) =>
      EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom);

  static const dateButtonPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 10,
  );

  static const choicePadding = EdgeInsets.symmetric(vertical: 8);

  static final dateButton = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.brandBlack,
    padding: FarmerDiscountDialogStyles.dateButtonPadding,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final saveButton = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 0,
  );

  static final choiceRadius = BorderRadius.circular(8);

  static const choiceTextSelected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.authGreen,
  );

  static const choiceTextUnselected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.brandBlack,
  );

  static final choiceSelected = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AgrisellColors.authGreen, width: 1.5),
  );

  static final choiceUnselected = BoxDecoration(
    color: AgrisellColors.homeBackground,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AgrisellColors.borderLine, width: 1),
  );
}
