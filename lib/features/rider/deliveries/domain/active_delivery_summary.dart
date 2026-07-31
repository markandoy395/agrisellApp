import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';

class ActiveDeliverySummary {
  const ActiveDeliverySummary({
    required this.deliveryId,
    required this.orderNumber,
    required this.productName,
    required this.sellerName,
    required this.buyerName,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupDeadline,
    required this.deliveryFee,
  });

  factory ActiveDeliverySummary.fromRequest(DeliveryRequest request) =>
      ActiveDeliverySummary(
        deliveryId: request.id,
        orderNumber: request.orderNumber,
        productName: request.productName,
        sellerName: request.sellerName,
        buyerName: request.buyerName,
        pickupAddress: request.pickupLocation.address,
        destinationAddress: request.deliveryLocation.address,
        pickupDeadline: request.pickupDeadline,
        deliveryFee: request.deliveryFee,
      );

  final String deliveryId;
  final String orderNumber;
  final String productName;
  final String sellerName;
  final String buyerName;
  final String pickupAddress;
  final String destinationAddress;
  final DateTime pickupDeadline;
  final double deliveryFee;

  DeliveryRequest toLegacyRequest({
    required String riderId,
    required DeliveryStatus status,
  }) => DeliveryRequest(
    id: deliveryId,
    orderNumber: orderNumber,
    productName: productName,
    sellerName: sellerName,
    buyerName: buyerName,
    pickupLocation: DeliveryLocation(address: pickupAddress),
    deliveryLocation: DeliveryLocation(address: destinationAddress),
    pickupDeadline: pickupDeadline,
    deliveryFee: deliveryFee,
    stage: legacyStageForDeliveryStatus(status),
    assignedRiderId: riderId,
  );

  Map<String, Object> toJson() => {
    'deliveryId': deliveryId,
    'orderNumber': orderNumber,
    'productName': productName,
    'sellerName': sellerName,
    'buyerName': buyerName,
    'pickupAddress': pickupAddress,
    'destinationAddress': destinationAddress,
    'pickupDeadline': pickupDeadline.toUtc().toIso8601String(),
    'deliveryFee': deliveryFee,
  };

  factory ActiveDeliverySummary.fromJson(Map<String, Object?> json) =>
      ActiveDeliverySummary(
        deliveryId: json['deliveryId'] as String,
        orderNumber: json['orderNumber'] as String,
        productName: json['productName'] as String,
        sellerName: json['sellerName'] as String,
        buyerName: json['buyerName'] as String,
        pickupAddress: json['pickupAddress'] as String,
        destinationAddress: json['destinationAddress'] as String,
        pickupDeadline: DateTime.parse(
          json['pickupDeadline'] as String,
        ).toLocal(),
        deliveryFee: (json['deliveryFee'] as num).toDouble(),
      );
}
