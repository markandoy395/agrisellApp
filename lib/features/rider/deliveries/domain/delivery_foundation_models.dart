import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';

export 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';

class DeliveryProduct {
  DeliveryProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.weightKg,
    this.imageUrl,
    Iterable<ProductHandlingRequirement> handlingRequirements = const [],
  }) : handlingRequirements = List.unmodifiable(handlingRequirements);

  final String id;
  final String name;
  final double quantity;
  final String unit;
  final double? weightKg;
  final String? imageUrl;
  final List<ProductHandlingRequirement> handlingRequirements;
}

class PickupLocation extends DeliveryLocation {
  const PickupLocation({
    required super.address,
    super.latitude,
    super.longitude,
    super.contactName,
    super.contactNumber,
    super.instructions,
  });
}

class DeliveryDestination extends DeliveryLocation {
  const DeliveryDestination({
    required super.address,
    super.latitude,
    super.longitude,
    this.recipientName,
    super.contactNumber,
    super.instructions,
  });

  final String? recipientName;
}

class DeliveryAssignment {
  const DeliveryAssignment({
    required this.assignmentId,
    required this.deliveryId,
    required this.riderId,
    required this.assignedAt,
    this.reservedUntil,
    this.acceptedAt,
  });

  final String assignmentId;
  final String deliveryId;
  final String riderId;
  final DateTime assignedAt;
  final DateTime? reservedUntil;
  final DateTime? acceptedAt;
}
