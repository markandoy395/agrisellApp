import 'package:agresell_app/features/shared/products/domain/home_product.dart';

class BasketCartItem {
  const BasketCartItem({
    required this.productId,
    required this.productName,
    required this.image,
    required this.sellerName,
    required this.sellerLocation,
    required this.harvestDate,
    required this.availableWeight,
    required this.priceLabel,
    required this.pricePerKg,
    required this.unit,
    required this.quantity,
    required this.isSelected,
    this.imageUrl,
    this.farmId,
  });

  factory BasketCartItem.fromProduct(HomeProduct product, {int quantity = 1}) {
    return BasketCartItem(
      productId: product.id,
      productName: product.name,
      image: product.image,
      imageUrl: product.imageUrl,
      sellerName: product.sellerName,
      sellerLocation: product.sellerLocation,
      harvestDate: product.harvestDate,
      availableWeight: product.availableWeight,
      priceLabel: product.price,
      pricePerKg: _priceFrom(product.price),
      unit: product.unit,
      quantity: quantity < 1 ? 1 : quantity,
      isSelected: true,
      farmId: product.farmId,
    );
  }

  final String productId;
  final String productName;
  final String image;
  final String? imageUrl;
  final String sellerName;
  final String sellerLocation;
  final String harvestDate;
  final String availableWeight;
  final String priceLabel;
  final double pricePerKg;
  final String unit;
  final int quantity;
  final bool isSelected;
  final int? farmId;

  double get selectedTotal => isSelected ? quantity * pricePerKg : 0;

  BasketCartItem copyWith({int? quantity, bool? isSelected}) {
    return BasketCartItem(
      productId: productId,
      productName: productName,
      image: image,
      imageUrl: imageUrl,
      sellerName: sellerName,
      sellerLocation: sellerLocation,
      harvestDate: harvestDate,
      availableWeight: availableWeight,
      priceLabel: priceLabel,
      pricePerKg: pricePerKg,
      unit: unit,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      farmId: farmId,
    );
  }

  static double _priceFrom(String price) {
    final normalized = price.replaceAll(',', '');
    final match = _pricePattern.firstMatch(normalized);

    if (match == null) {
      return 0;
    }

    return double.tryParse(match.group(0) ?? '') ?? 0;
  }
}

final _pricePattern = RegExp(r'\d+(?:\.\d+)?');
