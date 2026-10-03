import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';
import 'package:agresell_app/features/shared/waybills/services/waybill_html_template.dart';

String formatWaybillPlainText(DeliveryWaybill waybill) {
  final buffer = StringBuffer();
  buffer.writeln('=== AGRISELL DELIVERY WAYBILL ===');
  buffer.writeln('Waybill: ${waybill.waybillNumber}');
  buffer.writeln('Order: ORD-${waybill.orderId}');
  buffer.writeln('Date: ${waybill.schedule}');
  buffer.writeln('---------------------------------');
  buffer.writeln('CUSTOMER: ${waybill.buyerName}');
  buffer.writeln('CONTACT: ${waybill.buyerContact}');
  buffer.writeln('DELIVER TO: ${waybill.deliveryAddress}');
  buffer.writeln('---------------------------------');
  buffer.writeln('SHIPPER: ${waybill.sellerName}');
  buffer.writeln('PICKUP: ${waybill.pickupAddress}');
  if (waybill.pickupContact.isNotEmpty) {
    buffer.writeln('PICKUP CONTACT: ${waybill.pickupContact}');
  }
  buffer.writeln('---------------------------------');
  buffer.writeln('COURIER: ${waybill.courierName}');
  if (waybill.courierContact.isNotEmpty) {
    buffer.writeln('COURIER INFO: ${waybill.courierContact}');
  }
  buffer.writeln('---------------------------------');
  buffer.writeln('ITEMS:');
  for (final item in waybill.items) {
    buffer.writeln(
      ' - ${item.name} (${item.quantityDescription}): ${formatWaybillCurrency(item.total)}',
    );
  }
  buffer.writeln('---------------------------------');
  buffer.writeln(
    'PAYMENT: ${waybill.paymentMethod} (${waybill.paymentStatus})',
  );
  if (waybill.isCod) {
    buffer.writeln('COLLECT COD: ${formatWaybillCurrency(waybill.codAmount)}');
  }
  buffer.writeln('TOTAL: ${formatWaybillCurrency(waybill.totalAmount)}');
  if (waybill.instructions != null && waybill.instructions!.isNotEmpty) {
    buffer.writeln('INSTRUCTIONS: ${waybill.instructions}');
  }
  buffer.writeln('=================================');
  return buffer.toString();
}
