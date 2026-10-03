import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/farmer_restock_dialog.dart';

abstract final class FarmerProductRestockCoordinator {
  static Future<void> handleRestockProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required FarmerDashboardProduct product,
    required Set<int> restockingProductIds,
    required void Function(int id, bool isRestocking) onRestockStateChanged,
    required void Function(String message) onMessage,
    required void Function(FarmerDashboardProduct product) onRestocked,
  }) async {
    final commodityId = product.commodityId;
    if (commodityId == null || commodityId <= 0) {
      onMessage('Save this product before adding stock.');
      return;
    }
    if (restockingProductIds.contains(commodityId)) return;

    final request = await showFarmerRestockDialog(context, product: product);
    if (request == null || !context.mounted) return;

    onRestockStateChanged(commodityId, true);
    try {
      final updatedProduct = await repository.restock(
        product: product,
        quantity: request.quantity,
        inventoryLot: request.inventoryLot,
        reason: request.reason,
      );
      if (!context.mounted) return;
      onRestocked(updatedProduct);
      onMessage(
        '${updatedProduct.name} now has ${updatedProduct.availableWeight} in stock.',
      );
    } on FarmerCommodityException catch (error) {
      if (context.mounted) onMessage(error.message);
    } on Object {
      if (context.mounted) {
        onMessage('Stock could not be added. Please try again.');
      }
    } finally {
      if (context.mounted) onRestockStateChanged(commodityId, false);
    }
  }

  static Future<void> handleRestockProductByIndex({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required List<FarmerDashboardProduct> products,
    required int index,
    required Set<int> restockingProductIds,
    required void Function(int id, bool isRestocking) onRestockStateChanged,
    required void Function(String message) onMessage,
    required void Function() onUpdated,
  }) async {
    if (index < 0 || index >= products.length) return;
    await handleRestockProduct(
      context: context,
      repository: repository,
      product: products[index],
      restockingProductIds: restockingProductIds,
      onRestockStateChanged: onRestockStateChanged,
      onMessage: onMessage,
      onRestocked: (updated) {
        products[index] = updated;
        onUpdated();
      },
    );
  }
}
