import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import 'package:agresell_app/features/farmer/discounts/presentation/widgets/farmer_discount_dialog.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_form_message.dart';
import '../styles/farmer_product_edit_styles.dart';

class FarmerProductDiscountState {
  const FarmerProductDiscountState({
    this.name,
    this.discount,
    this.id,
    this.isFarmerOwned = false,
    this.type,
    this.value,
    this.promoCode,
    this.startsAt,
    this.endsAt,
  });

  final String? name;
  final String? discount;
  final int? id;
  final bool isFarmerOwned;
  final String? type;
  final double? value;
  final String? promoCode;
  final DateTime? startsAt;
  final DateTime? endsAt;

  String? get notice {
    if (name == null || name!.trim().isEmpty) return null;
    return '$name (${discount ?? 'Discounted'})';
  }

  static const empty = FarmerProductDiscountState();
}

abstract final class FarmerProductDiscountCoordinator {
  static Future<FarmerProductDiscountState?> manageDiscount({
    required BuildContext context,
    required FarmerDashboardProduct product,
    required FarmerDiscountRepository discountRepository,
    required FarmerProductDiscountState currentDiscount,
  }) async {
    final farmId = product.farmId;
    if (farmId == null) {
      showProductFormMessage(
        context,
        'Please save product before adding discount.',
      );
      return null;
    }

    FarmerDiscount? existing;
    if (currentDiscount.id != null && currentDiscount.isFarmerOwned) {
      existing = FarmerDiscount(
        saleId: currentDiscount.id!,
        farmId: farmId,
        name: currentDiscount.name ?? 'Product Discount',
        discountType: currentDiscount.type ?? 'percentage',
        discountValue: currentDiscount.value ?? 0.0,
        startsAt: currentDiscount.startsAt,
        endsAt: currentDiscount.endsAt,
        promoCode: currentDiscount.promoCode,
        commodityIds:
            product.commodityId != null ? [product.commodityId!] : [],
      );
    }

    final saved = await showFarmerDiscountDialog(
      context,
      farmId: farmId,
      existingDiscount: existing,
      initialProduct: product,
      discountRepository: discountRepository,
    );

    if (saved != null && context.mounted) {
      showProductFormMessage(
        context,
        'Discount applied: ${saved.discountLabel}',
      );
      return FarmerProductDiscountState(
        id: saved.saleId,
        isFarmerOwned: true,
        name: saved.name,
        discount: saved.discountLabel,
        type: saved.discountType,
        value: saved.discountValue,
        promoCode: saved.promoCode,
        startsAt: saved.startsAt,
        endsAt: saved.endsAt,
      );
    }
    return null;
  }

  static Future<bool> confirmAndRemoveDiscount({
    required BuildContext context,
    required int? saleId,
    required int? farmId,
    required FarmerDiscountRepository discountRepository,
  }) async {
    if (saleId == null || farmId == null) return false;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Discount?'),
        content: const Text(
          'Are you sure you want to remove the discount from this product?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FarmerProductEditStyles.removeDialogConfirmButtonStyle,
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return false;

    try {
      await discountRepository.deleteDiscount(saleId, farmId);
      if (!context.mounted) return false;
      showProductFormMessage(context, 'Discount removed.');
      return true;
    } catch (_) {
      if (!context.mounted) return false;
      showProductFormMessage(context, 'Failed to remove discount.');
      return false;
    }
  }
}
