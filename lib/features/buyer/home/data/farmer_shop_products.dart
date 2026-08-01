import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

FarmerProfile? farmerForProduct(HomeProduct product) {
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
