import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/shared/orders/domain/order_feedback.dart';

class PlacedOrderItem {
  const PlacedOrderItem({
    required this.productId,
    required this.productName,
    required this.image,
    required this.sellerName,
    required this.pricePerKg,
    required this.unit,
    required this.quantity,
    this.imageUrl,
    this.feedback,
  });

  factory PlacedOrderItem.fromBasketItem(BasketCartItem item) {
    return PlacedOrderItem(
      productId: item.productId,
      productName: item.productName,
      image: item.image,
      imageUrl: item.imageUrl,
      sellerName: item.sellerName,
      pricePerKg: item.pricePerKg,
      unit: item.unit,
      quantity: item.quantity,
    );
  }

  final String productId;
  final String productName;
  final String image;
  final String? imageUrl;
  final String sellerName;
  final double pricePerKg;
  final String unit;
  final int quantity;
  final OrderFeedback? feedback;

  double get total => pricePerKg * quantity;

  PlacedOrderItem copyWith({OrderFeedback? feedback}) => PlacedOrderItem(
    productId: productId,
    productName: productName,
    image: image,
    imageUrl: imageUrl,
    sellerName: sellerName,
    pricePerKg: pricePerKg,
    unit: unit,
    quantity: quantity,
    feedback: feedback ?? this.feedback,
  );
}
