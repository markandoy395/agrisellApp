import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/dashboard/presentation/utils/farmer_product_editor_coordinator.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/utils/farmer_product_filter_coordinator.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/utils/farmer_product_restock_coordinator.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/utils/farmer_verification_coordinator.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_image_picker.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';

export 'package:agresell_app/features/farmer/dashboard/presentation/utils/farmer_product_editor_coordinator.dart';
export 'package:agresell_app/features/farmer/dashboard/presentation/utils/farmer_product_filter_coordinator.dart';
export 'package:agresell_app/features/farmer/dashboard/presentation/utils/farmer_product_restock_coordinator.dart';
export 'package:agresell_app/features/farmer/dashboard/presentation/utils/farmer_verification_coordinator.dart';

abstract final class FarmerProductCoordinator {
  static List<FarmerDashboardProduct> filterProducts({
    required List<FarmerDashboardProduct> products,
    required String category,
    required String query,
  }) => FarmerProductFilterCoordinator.filterProducts(
    products: products,
    category: category,
    query: query,
  );

  static Future<FarmerDashboardProduct> saveToDatabase({
    required FarmerCommodityRepository repository,
    required FarmerDashboardProduct product,
  }) => FarmerProductEditorCoordinator.saveToDatabase(
    repository: repository,
    product: product,
  );

  static Future<FarmerDashboardProduct?> saveProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required FarmerDashboardProduct product,
    required void Function(String message) onMessage,
  }) => FarmerProductEditorCoordinator.saveProduct(
    context: context,
    repository: repository,
    product: product,
    onMessage: onMessage,
  );

  static Future<FarmerDashboardProduct?> addNewProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required ProductImagePicker? pickProductImageBytes,
    required void Function(String message) onMessage,
  }) => FarmerProductEditorCoordinator.addNewProduct(
    context: context,
    repository: repository,
    pickProductImageBytes: pickProductImageBytes,
    onMessage: onMessage,
  );

  static Future<void> handleAddProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required ProductImagePicker? pickProductImageBytes,
    required bool canPostProducts,
    required void Function(String message) onMessage,
    required void Function(FarmerDashboardProduct product) onSaved,
  }) => FarmerProductEditorCoordinator.handleAddProduct(
    context: context,
    repository: repository,
    pickProductImageBytes: pickProductImageBytes,
    canPostProducts: canPostProducts,
    onMessage: onMessage,
    onSaved: onSaved,
  );

  static Future<FarmerDashboardProduct?> editProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required FarmerDashboardProduct product,
    required ProductImagePicker? pickProductImageBytes,
    required void Function(String message) onMessage,
  }) => FarmerProductEditorCoordinator.editProduct(
    context: context,
    repository: repository,
    product: product,
    pickProductImageBytes: pickProductImageBytes,
    onMessage: onMessage,
  );

  static Future<void> handleEditProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required FarmerDashboardProduct product,
    required ProductImagePicker? pickProductImageBytes,
    required void Function(String message) onMessage,
    required void Function(FarmerDashboardProduct product) onSaved,
  }) => FarmerProductEditorCoordinator.handleEditProduct(
    context: context,
    repository: repository,
    product: product,
    pickProductImageBytes: pickProductImageBytes,
    onMessage: onMessage,
    onSaved: onSaved,
  );

  static Future<void> handleEditProductByIndex({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required List<FarmerDashboardProduct> products,
    required int index,
    required ProductImagePicker? pickProductImageBytes,
    required void Function(String message) onMessage,
    required void Function() onUpdated,
  }) => FarmerProductEditorCoordinator.handleEditProductByIndex(
    context: context,
    repository: repository,
    products: products,
    index: index,
    pickProductImageBytes: pickProductImageBytes,
    onMessage: onMessage,
    onUpdated: onUpdated,
  );

  static Future<void> handleRestockProduct({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required FarmerDashboardProduct product,
    required Set<int> restockingProductIds,
    required void Function(int id, bool isRestocking) onRestockStateChanged,
    required void Function(String message) onMessage,
    required void Function(FarmerDashboardProduct product) onRestocked,
  }) => FarmerProductRestockCoordinator.handleRestockProduct(
    context: context,
    repository: repository,
    product: product,
    restockingProductIds: restockingProductIds,
    onRestockStateChanged: onRestockStateChanged,
    onMessage: onMessage,
    onRestocked: onRestocked,
  );

  static Future<void> handleRestockProductByIndex({
    required BuildContext context,
    required FarmerCommodityRepository repository,
    required List<FarmerDashboardProduct> products,
    required int index,
    required Set<int> restockingProductIds,
    required void Function(int id, bool isRestocking) onRestockStateChanged,
    required void Function(String message) onMessage,
    required void Function() onUpdated,
  }) => FarmerProductRestockCoordinator.handleRestockProductByIndex(
    context: context,
    repository: repository,
    products: products,
    index: index,
    restockingProductIds: restockingProductIds,
    onRestockStateChanged: onRestockStateChanged,
    onMessage: onMessage,
    onUpdated: onUpdated,
  );

  static Future<List<FarmerDashboardProduct>> loadProducts({
    required FarmerCommodityRepository repository,
    required void Function(String message) onMessage,
  }) async {
    if (!repository.isAvailable) return const [];
    try {
      return await repository.loadProducts();
    } on FarmerCommodityException catch (error) {
      onMessage(error.message);
      return const [];
    }
  }

  static Future<FarmerVerificationDetails?> loadVerificationDetails(
    FarmerVerificationRepository repository,
  ) => FarmerVerificationCoordinator.loadVerificationDetails(repository);

  static Future<FarmerVerificationDetails?> resubmitInformation({
    required BuildContext context,
    required FarmerVerificationRepository repository,
    required FarmerVerificationDetails? details,
  }) => FarmerVerificationCoordinator.resubmitInformation(
    context: context,
    repository: repository,
    details: details,
  );
}
