import 'package:flutter/material.dart';
import 'package:agresell_app/features/buyer/deals/presentation/styles/voucher_card_styles.dart';

abstract final class VoucherCardHeaderStyles {
  static final _containerDecorationActive = BoxDecoration(
    color: VoucherCardStyles.headerColor(isFarmer: true),
    border: VoucherCardStyles.headerBorder,
  );
  static final _containerDecorationInactive = BoxDecoration(
    color: VoucherCardStyles.headerColor(isFarmer: false),
    border: VoucherCardStyles.headerBorder,
  );
  static BoxDecoration containerDecoration(bool isFarmer) =>
      isFarmer ? _containerDecorationActive : _containerDecorationInactive;
}
