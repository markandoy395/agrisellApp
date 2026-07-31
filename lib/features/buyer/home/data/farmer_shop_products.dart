import 'package:agresell_app/features/buyer/home/data/farmer_profiles.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

/// Populated by the backend products repository using the selected farmer ID.
List<HomeProduct> farmerShopProductsFor(FarmerProfile farmer) =>
    const <HomeProduct>[];

FarmerProfile? farmerForProduct(HomeProduct product) {
  for (final farmer in farmerProfiles) {
    if (farmer.farmId == product.farmId || farmer.name == product.sellerName) {
      return farmer;
    }
  }
  final farmId = product.farmId;
  if (farmId == null || farmId <= 0) return null;
  return FarmerProfile(
    farmId: farmId,
    name: product.sellerName,
    location: product.sellerLocation,
    rating: product.rating,
    coverImage: product.image,
    products: const [],
  );
}
