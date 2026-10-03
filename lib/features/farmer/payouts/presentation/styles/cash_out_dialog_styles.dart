import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

import 'payout_surface_styles.dart';
import 'payout_text_styles.dart';

abstract final class CashOutDialogStyles {
  static const transparent = PayoutSurfaceStyles.transparent;
  static const white = PayoutSurfaceStyles.white;
  static const green = AgrisellColors.authGreen;
  static const muted = AgrisellColors.mutedText;
  static const errorColor = Colors.red;
  static const title = PayoutTextStyles.heading;
  static const description = PayoutTextStyles.caption;
  static const methodSubtitle = PayoutTextStyles.mutedLabel;
  static final dragHandle = PayoutSurfaceStyles.dragHandle;

  static const sheet = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );
  static EdgeInsets keyboardPadding(BuildContext context) =>
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom);
  static const formConstraints = BoxConstraints(maxWidth: 500);
  static const closeConstraints = BoxConstraints();
  static const formPadding = EdgeInsets.fromLTRB(22, 12, 22, 24);
  static const handleMargin = EdgeInsets.only(bottom: 14);
  static const headerIconPadding = EdgeInsets.all(8);
  static const errorPadding = EdgeInsets.all(10);
  static const methodPadding = EdgeInsets.all(12);
  static const closePadding = EdgeInsets.zero;

  static const headerIcon = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );
  static const errorPanel = BoxDecoration(
    color: PayoutSurfaceStyles.failedBackground,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  static const errorText = TextStyle(
    color: Colors.red,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );
  static const amountPrefix = TextStyle(
    fontWeight: FontWeight.w700,
    color: AgrisellColors.headingGreen,
  );
  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none,
  );
  static const _inputPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static InputDecoration inputDecoration(
    String hintText, {
    bool isAmount = false,
  }) => InputDecoration(
    hintText: hintText,
    prefixText: isAmount ? '\u20b1 ' : null,
    prefixStyle: isAmount ? amountPrefix : null,
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    border: _inputBorder,
    contentPadding: _inputPadding,
  );

  static const cancelText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontWeight: FontWeight.w700,
  );
  static const submitText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w700,
  );
  static final cancelButton = OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    side: const BorderSide(color: AgrisellColors.borderLine),
  );
  static final submitButton = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    padding: const EdgeInsets.symmetric(vertical: 12),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );

  static const methodRadius = BorderRadius.all(Radius.circular(10));
  static const selectedMethod = BoxDecoration(
    color: AgrisellColors.statusGreenBackground,
    borderRadius: methodRadius,
    border: Border.fromBorderSide(
      BorderSide(color: AgrisellColors.authGreen, width: 1.5),
    ),
  );
  static const unselectedMethod = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: methodRadius,
    border: Border.fromBorderSide(
      BorderSide(color: Colors.transparent, width: 1.5),
    ),
  );
  static const selectedMethodTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.authGreen,
  );
  static const unselectedMethodTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.brandBlack,
  );
}
