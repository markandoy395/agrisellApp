import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class DeliveryWaybillItem {
  const DeliveryWaybillItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.total,
  });

  final String name;
  final int quantity;
  final String unit;
  final double unitPrice;
  final double total;

  String get quantityDescription => '$quantity $unit';
}

class DeliveryWaybill {
  DeliveryWaybill({
    required this.orderId,
    required this.waybillNumber,
    required this.buyerName,
    required this.buyerContact,
    required this.deliveryAddress,
    required this.sellerName,
    required this.pickupAddress,
    required this.pickupContact,
    required this.courierName,
    required this.courierContact,
    required this.schedule,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    required List<DeliveryWaybillItem> items,
    this.isCod = false,
    this.codAmount = 0,
    this.instructions,
    this.weightKg,
    this.packageDimensions,
    List<String> handlingRequirements = const [],
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now(),
       items = List.unmodifiable(items),
       handlingRequirements = List.unmodifiable(handlingRequirements);

  final String orderId;
  final String waybillNumber;
  final String buyerName;
  final String buyerContact;
  final String deliveryAddress;
  final String sellerName;
  final String pickupAddress;
  final String pickupContact;
  final String courierName;
  final String courierContact;
  final String schedule;
  final String paymentMethod;
  final String paymentStatus;
  final double totalAmount;
  final bool isCod;
  final double codAmount;
  final List<DeliveryWaybillItem> items;
  final String? instructions;
  final double? weightKg;
  final String? packageDimensions;
  final List<String> handlingRequirements;
  final DateTime generatedAt;

  factory DeliveryWaybill.fromFarmerOrder(
    PlacedOrder order, {
    String? courierName,
    String? courierContact,
    dynamic riderRequest,
    String? farmerContact,
    String? pickupAddress,
  }) {
    final isCod = order.payment.method == OrderPaymentMethod.cashOnDelivery;
    final courier = riderRequest?.riderName ??
        (courierName != null && courierName.isNotEmpty ? courierName : 'Unassigned');
    final courierLocation = riderRequest != null
        ? '${riderRequest.riderBarangay}, ${riderRequest.riderMunicipality}'
        : (courierContact != null && courierContact.isNotEmpty
            ? courierContact
            : 'Pending assignment');

    final waybillItems = order.items
        .map(
          (item) => DeliveryWaybillItem(
            name: item.productName,
            quantity: item.quantity,
            unit: item.unit.isNotEmpty ? item.unit : 'kg',
            unitPrice: item.pricePerKg,
            total: item.total,
          ),
        )
        .toList(growable: false);

    final resolvedSellerName = order.sellerLine.isNotEmpty
        ? order.sellerLine
        : 'Farm Seller';
    final resolvedPickup = pickupAddress != null && pickupAddress.isNotEmpty
        ? pickupAddress
        : 'Farm pickup location';

    return DeliveryWaybill(
      orderId: order.id,
      waybillNumber: 'WB-${order.id}',
      buyerName: order.buyerName.isNotEmpty ? order.buyerName : 'Customer',
      buyerContact: order.phoneNumber.isNotEmpty ? order.phoneNumber : 'Not recorded',
      deliveryAddress: order.deliveryAddress.isNotEmpty
          ? order.deliveryAddress
          : 'Delivery address not recorded',
      sellerName: resolvedSellerName,
      pickupAddress: resolvedPickup,
      pickupContact: farmerContact ?? '',
      courierName: courier,
      courierContact: courierLocation,
      schedule: _formatSchedule(order.placedAt),
      paymentMethod: order.payment.method.name.toUpperCase(),
      paymentStatus: order.payment.status.name.toUpperCase(),
      totalAmount: order.total,
      isCod: isCod,
      codAmount: isCod ? order.total : 0,
      items: waybillItems,
    );
  }

  factory DeliveryWaybill.fromRiderDelivery(
    dynamic request, {
    required String riderName,
    required String riderContact,
  }) {
    final isCod = request.isCashOnDelivery;
    final codVal = request.cashOnDelivery?.amountToCollect ?? 0.0;
    return DeliveryWaybill(
      orderId: request.orderNumber,
      waybillNumber: 'WB-${request.orderNumber}',
      buyerName: request.buyerName,
      buyerContact: (request.deliveryLocation.contactNumber != null &&
              request.deliveryLocation.contactNumber!.isNotEmpty)
          ? request.deliveryLocation.contactNumber!
          : 'Not recorded',
      deliveryAddress: request.deliveryLocation.address.isNotEmpty
          ? request.deliveryLocation.address
          : 'Delivery address not recorded',
      sellerName: request.sellerName,
      pickupAddress: request.pickupLocation.address.isNotEmpty
          ? request.pickupLocation.address
          : 'Farm pickup location',
      pickupContact: request.pickupLocation.contactNumber ?? '',
      courierName: riderName,
      courierContact: riderContact,
      schedule: _formatSchedule(request.pickupDeadline),
      paymentMethod: request.paymentMethod.isNotEmpty ? request.paymentMethod : (isCod ? 'COD' : 'ONLINE'),
      paymentStatus: 'PAID',
      totalAmount: codVal > 0 ? codVal : request.deliveryFee,
      isCod: isCod,
      codAmount: codVal,
      instructions: [
        if (request.pickupInstructions.isNotEmpty) request.pickupInstructions,
        if (request.deliveryInstructions.isNotEmpty) request.deliveryInstructions,
      ].join(' | '),
      items: [
        DeliveryWaybillItem(
          name: request.productName,
          quantity: 1,
          unit: 'pkg',
          unitPrice: codVal > 0 ? codVal : request.deliveryFee,
          total: codVal > 0 ? codVal : request.deliveryFee,
        ),
      ],
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
