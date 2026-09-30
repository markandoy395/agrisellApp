import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';

extension RiderDeliveryWaybillExtension on DeliveryRequest {
  DeliveryWaybill toWaybill({String? riderName, String? riderContact}) {
    final isCod = cashOnDelivery != null;
    final codAmount = cashOnDelivery?.amountToCollect ?? 0;
    final courier = riderName != null && riderName.isNotEmpty
        ? riderName
        : assignedRiderId != null && assignedRiderId!.isNotEmpty
            ? 'Assigned Rider ($assignedRiderId)'
            : 'Unassigned';

    final waybillItems = [
      DeliveryWaybillItem(
        name: productName,
        quantity: 1,
        unit: quantityDescription.isNotEmpty ? quantityDescription : 'unit',
        unitPrice: deliveryFee,
        total: deliveryFee,
      ),
    ];

    final instructions = [
      if (pickupInstructions.isNotEmpty) 'Pickup: $pickupInstructions',
      if (deliveryInstructions.isNotEmpty) 'Delivery: $deliveryInstructions',
    ].join(' | ');

    final buyerContact = deliveryLocation.contactNumber;
    final pickupContact = pickupLocation.contactNumber;

    return DeliveryWaybill(
      orderId: orderNumber,
      waybillNumber: 'WB-$orderNumber',
      buyerName: buyerName.isNotEmpty ? buyerName : 'Customer',
      buyerContact: buyerContact != null && buyerContact.isNotEmpty
          ? buyerContact
          : 'Not recorded',
      deliveryAddress: deliveryLocation.address.isNotEmpty
          ? deliveryLocation.address
          : 'Dropoff location not recorded',
      sellerName: sellerName.isNotEmpty ? sellerName : 'Farmer',
      pickupAddress: pickupLocation.address.isNotEmpty
          ? pickupLocation.address
          : 'Pickup location not recorded',
      pickupContact: pickupContact != null && pickupContact.isNotEmpty
          ? pickupContact
          : 'Not recorded',
      courierName: courier,
      courierContact: riderContact ?? '',
      schedule: _formatSchedule(pickupDeadline),
      paymentMethod: paymentMethod.isNotEmpty
          ? paymentMethod.toUpperCase()
          : (isCod ? 'CASH ON DELIVERY' : 'PREPAID'),
      paymentStatus: isCod ? 'COLLECT ON DELIVERY' : 'PAID',
      totalAmount: isCod ? codAmount : deliveryFee,
      isCod: isCod,
      codAmount: codAmount,
      items: waybillItems,
      instructions: instructions.isNotEmpty ? instructions : null,
      weightKg: totalWeightKg,
      packageDimensions: packageDimensions?.toString(),
      handlingRequirements: handlingRequirements
          .map((r) => r.type.label)
          .toList(growable: false),
    );
  }

  static String _formatSchedule(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}
