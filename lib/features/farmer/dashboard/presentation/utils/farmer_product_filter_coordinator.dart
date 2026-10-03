import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';

abstract final class FarmerProductFilterCoordinator {
  static List<FarmerDashboardProduct> filterProducts({
    required List<FarmerDashboardProduct> products,
    required String category,
    required String query,
  }) {
    final trimmedQuery = query.trim().toLowerCase();
    return [
      for (final product in products)
        if ((category == 'All' || product.category == category) &&
            (trimmedQuery.isEmpty ||
                product.name.toLowerCase().contains(trimmedQuery) ||
                product.category.toLowerCase().contains(trimmedQuery) ||
                product.description.toLowerCase().contains(trimmedQuery)))
          product,
    ];
  }
}
