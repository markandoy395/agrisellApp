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
    this.originalPriceLabel,
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
      priceLabel: product.activePrice,
      originalPriceLabel: product.hasSale ? product.price : null,
      pricePerKg: _priceFrom(product.activePrice),
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
  final String? originalPriceLabel;
  final double pricePerKg;
  final String unit;
  final int quantity;
  final bool isSelected;
  final int? farmId;

  double get selectedTotal => isSelected ? quantity * pricePerKg : 0;

  BasketCartItem copyWith({
    int? quantity,
    bool? isSelected,
    double? pricePerKg,
    String? priceLabel,
  }) {
    return BasketCartItem(
      productId: productId,
      productName: productName,
      image: image,
      imageUrl: imageUrl,
      sellerName: sellerName,
      sellerLocation: sellerLocation,
      harvestDate: harvestDate,
      availableWeight: availableWeight,
      priceLabel: priceLabel ?? this.priceLabel,
      originalPriceLabel: originalPriceLabel,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      unit: unit,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      farmId: farmId,
    );
  }

  bool get hasSale => originalPriceLabel != null;

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
