import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/product_edit_options.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_form_message.dart';
import 'package:agresell_app/features/farmer/products/presentation/utils/farmer_product_discount_coordinator.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

abstract final class FarmerProductEditBuilder {
  static FarmerDashboardProduct? build({
    required BuildContext context,
    required FarmerDashboardProduct baseProduct,
    required String name,
    required String price,
    required String weight,
    required String? day,
    required String? month,
    required String? year,
    required String? category,
    required String? imageAsset,
    required Uint8List? imageBytes,
    required String? imageUrl,
    required bool isSold,
    required ProductSaleStatus saleStatus,
    required ProductProductionStage productionStage,
    required FarmerProductDiscountState discount,
  }) {
    final trimmedName = name.trim();
    final trimmedPrice = price.trim();
    final trimmedWeight = weight.trim();
    final error = ProductEditOptions.validateForm(
      hasImage: imageAsset != null || imageBytes != null || imageUrl != null,
      name: trimmedName,
      price: trimmedPrice,
      weight: trimmedWeight,
      day: day,
      month: month,
      year: year,
      category: category,
      productionStage: productionStage,
      sellingOption: saleStatus,
    );
    if (error != null) {
      showProductFormMessage(context, error);
      return null;
    }
    final edited = ProductEditOptions.editedProduct(
      baseProduct: baseProduct,
      name: trimmedName,
      price: trimmedPrice,
      weight: trimmedWeight,
      day: day,
      month: month,
      year: year,
      category: category!,
      imageAsset: imageAsset,
      imageBytes: imageBytes,
      imageUrl: imageUrl,
      isSold: isSold,
      saleStatus: saleStatus,
      productionStage: productionStage,
    );
    return edited.copyWith(
      activeSaleId: discount.id,
      activeSaleIsFarmerOwned: discount.isFarmerOwned,
      activeSaleName: discount.name,
      activeSaleDiscount: discount.discount,
      activeSaleType: discount.type,
      activeSaleValue: discount.value,
      activeSalePromoCode: discount.promoCode,
      activeSaleStartsAt: discount.startsAt,
      activeSaleEndsAt: discount.endsAt,
      clearActiveSale: discount.name == null,
    );
  }
}
