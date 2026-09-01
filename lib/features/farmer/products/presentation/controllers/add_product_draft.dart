import 'dart:typed_data';

import 'package:agresell_app/features/shared/products/domain/product_availability_date_rules.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';

enum AddProductField {
  photo,
  name,
  category,
  description,
  price,
  quantity,
  minimumOrder,
  harvestDate,
  lotHarvestDate,
  marketableUntil,
  lotCode,
  storageInstructions,
}

abstract final class AddProductDraft {
  static Map<AddProductField, String> validationErrors({
    required Uint8List? photoBytes,
    required String name,
    required String category,
    required String description,
    required String price,
    required String quantity,
    required String minimumOrderQuantity,
    required ProductProductionStage productionStage,
    required ProductSaleStatus sellingOption,
    required DateTime? expectedDate,
    ProductInventoryLotDraft? inventoryLot,
  }) {
    final errors = <AddProductField, String>{};
    if (photoBytes == null) {
      errors[AddProductField.photo] = 'Add a clear product photo.';
    }
    if (name.isEmpty) {
      errors[AddProductField.name] = 'Enter the product name.';
    }
    if (category.isEmpty) {
      errors[AddProductField.category] = 'Select a category.';
    }
    if (description.isEmpty) {
      errors[AddProductField.description] = 'Describe the product.';
    } else if (description.length > 300) {
      errors[AddProductField.description] =
          'Keep the description within 300 characters.';
    }

    final parsedPrice = double.tryParse(price);
    if (parsedPrice == null || parsedPrice <= 0) {
      errors[AddProductField.price] = 'Enter a price greater than zero.';
    }
    final parsedQuantity = double.tryParse(quantity);
    if (parsedQuantity == null || parsedQuantity <= 0) {
      errors[AddProductField.quantity] =
          'Enter an available quantity greater than zero.';
    }
    final parsedMinimum = double.tryParse(minimumOrderQuantity);
    if (parsedMinimum == null || parsedMinimum <= 0) {
      errors[AddProductField.minimumOrder] =
          'Enter a minimum order greater than zero.';
    } else if (parsedQuantity != null && parsedMinimum > parsedQuantity) {
      errors[AddProductField.minimumOrder] =
          'Minimum order cannot exceed available quantity.';
    }

    final dateWindow = ProductAvailabilityDateRules.windowFor(
      productionStage: productionStage,
      sellingOption: sellingOption,
    );
    if (dateWindow.validationMessage(expectedDate) case final message?) {
      errors[AddProductField.harvestDate] = message;
    }
    if (inventoryLot != null) {
      final lotErrors = inventoryLot.validationErrors(
        today: ProductAvailabilityDateRules.philippineToday(),
        earliestMarketableDate: expectedDate,
        allowFutureHarvest: productionStage != ProductProductionStage.harvested,
      );
      if (lotErrors['harvestedAt'] case final message?) {
        errors[AddProductField.lotHarvestDate] = message;
      }
      if (lotErrors['sellUntil'] ?? lotErrors['expiresAt']
          case final message?) {
        errors[AddProductField.marketableUntil] = message;
      }
      if (lotErrors['lotCode'] case final message?) {
        errors[AddProductField.lotCode] = message;
      }
      if (lotErrors['storageInstructions'] case final message?) {
        errors[AddProductField.storageInstructions] = message;
      }
    }
    return errors;
  }
}
