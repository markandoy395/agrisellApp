import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_image_picker.dart';
import 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';
import 'package:agresell_app/features/farmer/products/presentation/screens/farmer_product_edit_screen.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/farm_creation_dialog.dart';

abstract final class FarmerProductEditorCoordinator {
  static Future<FarmerDashboardProduct> saveToDatabase({
    required FarmerCommodityRepository repository,
    required FarmerDashboardProduct product,
    String? requestKey,
  }) {
    if (!repository.isAvailable) {
      return Future.value(product);
    }
    return requestKey == null
        ? repository.save(product)
        : repository.publish(product, requestKey);
  }

  static Future<FarmerDashboardProduct?> saveProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required FarmerDashboardProduct product,
    required void Function(String message) onMessage,
    String? requestKey,
  }) async {
    try {
      return await saveToDatabase(
        repository: repository,
        product: product,
        requestKey: requestKey,
      );
    } on FarmRequiredException {
      if (!context.mounted) return null;
      final farmName = await showFarmCreationDialog(context);
      if (farmName == null || !context.mounted) return null;
      try {
        await repository.createFarm(farmName);
        return await saveToDatabase(
          repository: repository,
          product: product,
          requestKey: requestKey,
        );
      } on FarmerCommodityException catch (error) {
        if (context.mounted) onMessage(error.message);
        return null;
      }
    } on FarmerCommodityException catch (error) {
      if (context.mounted) onMessage(error.message);
      return null;
    } catch (_) {
      if (context.mounted) {
        onMessage('The product could not be saved. Please try again.');
      }
      return null;
    }
  }

  static Future<FarmerDashboardProduct?> addNewProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required ProductImagePicker? pickProductImageBytes,
    required void Function(String message) onMessage,
  }) async {
    return Navigator.of(context).push<FarmerDashboardProduct>(
      agrisellPageRoute<FarmerDashboardProduct>(
        builder: (_) => AddProductScreen(
          pickProductImageBytes: pickProductImageBytes,
          onPublish: (formContext, product, requestKey) => saveProduct(
            context: formContext,
            repository: repository,
            product: product,
            onMessage: onMessage,
            requestKey: requestKey,
          ),
        ),
      ),
    );
  }

  static Future<void> handleAddProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required ProductImagePicker? pickProductImageBytes,
    required bool canPostProducts,
    required void Function(String message) onMessage,
    required void Function(FarmerDashboardProduct product) onSaved,
  }) async {
    if (!canPostProducts) {
      onMessage(
        'Your farmer account must be verified before you can add products.',
      );
      return;
    }
    final saved = await addNewProduct(
      context: context,
      repository: repository,
      pickProductImageBytes: pickProductImageBytes,
      onMessage: onMessage,
    );
    if (saved != null && context.mounted) {
      onSaved(saved);
      onMessage('${saved.name} has been saved.');
    }
  }

  static Future<FarmerDashboardProduct?> editProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required FarmerDashboardProduct product,
    required ProductImagePicker? pickProductImageBytes,
    required void Function(String message) onMessage,
  }) async {
    final updatedProduct = await Navigator.of(context)
        .push<FarmerDashboardProduct>(
          agrisellPageRoute<FarmerDashboardProduct>(
            builder: (_) => FarmerProductEditScreen(
              product: product,
              pickProductImageBytes: pickProductImageBytes,
            ),
          ),
        );
    if (updatedProduct == null || !context.mounted) return null;
    return saveProduct(
      context: context,
      repository: repository,
      product: updatedProduct,
      onMessage: onMessage,
    );
  }

  static Future<void> handleEditProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required FarmerDashboardProduct product,
    required ProductImagePicker? pickProductImageBytes,
    required void Function(String message) onMessage,
    required void Function(FarmerDashboardProduct product) onSaved,
  }) async {
    final saved = await editProduct(
      context: context,
      repository: repository,
      product: product,
      pickProductImageBytes: pickProductImageBytes,
      onMessage: onMessage,
    );
    if (saved != null && context.mounted) {
      onSaved(saved);
      onMessage('${saved.name} has been saved.');
    }
  }

  static Future<void> handleEditProductByIndex({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required List<FarmerDashboardProduct> products,
    required int index,
    required ProductImagePicker? pickProductImageBytes,
    required void Function(String message) onMessage,
    required void Function() onUpdated,
  }) async {
    if (index < 0 || index >= products.length) return;
    await handleEditProduct(
      context: context,
      repository: repository,
      product: products[index],
      pickProductImageBytes: pickProductImageBytes,
      onMessage: onMessage,
      onSaved: (saved) {
        products[index] = saved;
        onUpdated();
      },
    );
  }
}
