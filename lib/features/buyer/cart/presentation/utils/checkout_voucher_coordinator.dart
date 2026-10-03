import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/buyer/cart/data/checkout_voucher_service.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_screen_styles.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/checkout/checkout_voucher_picker_sheet.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

class CheckoutVoucherCoordinator {
  CheckoutVoucherCoordinator({
    required this.voucherService,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController();

  final CheckoutVoucherService voucherService;
  final TextEditingController controller;
  AppliedVoucher? appliedVoucher;
  bool isValidating = false;
  String? voucherError;

  void dispose() {
    controller.dispose();
  }

  void removeVoucher() {
    appliedVoucher = null;
    voucherError = null;
    controller.clear();
  }

  Future<bool> applyVoucher(
    BuildContext context,
    List<BasketCartItem> items,
  ) async {
    final code = controller.text.trim();
    if (code.isEmpty) {
      voucherError = CheckoutScreenStyles.enterVoucherPrompt;
      return false;
    }

    isValidating = true;
    voucherError = null;
    try {
      final voucher = await voucherService.validateVoucher(
        code: code,
        items: items,
      );
      appliedVoucher = voucher;
      voucherError = null;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showAppSnackBar(
          CheckoutScreenStyles.snackBar(
            'Voucher "${voucher.code}" applied: ${voucher.discountLabel}',
          ),
        );
      }
      return true;
    } on VoucherValidationException catch (error) {
      voucherError = error.message;
      return false;
    } catch (_) {
      voucherError = CheckoutScreenStyles.voucherValidationFailure;
      return false;
    } finally {
      isValidating = false;
    }
  }

  Future<void> browseVouchers(
    BuildContext context,
    List<BasketCartItem> items,
    Future<void> Function() onSelect,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CheckoutVoucherPickerSheet(
        cartItems: items,
        onSelectVoucher: (voucher) {
          controller.text = voucher.code ?? '';
          unawaited(onSelect());
        },
      ),
    );
  }
}
