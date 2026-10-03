import 'package:agresell_app/features/shared/waybills/services/waybill_html_styles.dart';
import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';

String escapeHtml(Object? value) {
  if (value == null) return '';
  return value
      .toString()
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
}

String formatWaybillCurrency(double amount) {
  return 'PHP ${amount.toStringAsFixed(2)}';
}

String buildWaybillHtml(DeliveryWaybill waybill) {
  final orderIdEscaped = escapeHtml(waybill.orderId);
  final waybillNumberEscaped = escapeHtml(waybill.waybillNumber);
  final buyerNameEscaped = escapeHtml(waybill.buyerName);
  final buyerContactEscaped = escapeHtml(waybill.buyerContact);
  final deliveryAddressEscaped = escapeHtml(waybill.deliveryAddress);
  final sellerNameEscaped = escapeHtml(waybill.sellerName);
  final pickupAddressEscaped = escapeHtml(waybill.pickupAddress);
  final pickupContactEscaped = escapeHtml(waybill.pickupContact);
  final courierNameEscaped = escapeHtml(waybill.courierName);
  final courierContactEscaped = escapeHtml(waybill.courierContact);
  final scheduleEscaped = escapeHtml(waybill.schedule);
  final paymentMethodEscaped = escapeHtml(waybill.paymentMethod);
  final paymentStatusEscaped = escapeHtml(waybill.paymentStatus);
  final totalFormatted = formatWaybillCurrency(waybill.totalAmount);
  final codFormatted = formatWaybillCurrency(waybill.codAmount);

  final itemRows = waybill.items
      .map((item) {
        return '<tr>'
            '<td>${escapeHtml(item.name)}</td>'
            '<td class="quantity">${escapeHtml(item.quantityDescription)}</td>'
            '<td class="price">${formatWaybillCurrency(item.unitPrice)}</td>'
            '<td class="item-total">${formatWaybillCurrency(item.total)}</td>'
            '</tr>';
      })
      .join('\n');

  final instructionsHtml =
      waybill.instructions != null && waybill.instructions!.isNotEmpty
      ? '<div class="box wide"><strong>Instructions & Handling</strong>${escapeHtml(waybill.instructions)}</div>'
      : '';

  final codBadge = waybill.isCod
      ? '<span class="badge badge-cod">COLLECT COD: $codFormatted</span>'
      : '<span class="badge">PREPAID</span>';

  return '''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Waybill $waybillNumberEscaped</title>
  <style>$waybillHtmlStyles</style>
</head>
<body>
  <h1>AgriSell Delivery Waybill</h1>
  <div class="subhead">Official Marketplace Shipping & Package Receipt</div>
  <div class="id">ORD-$orderIdEscaped &middot; $waybillNumberEscaped</div>
  <div class="barcode">||| | |||| || | |||| |||||</div>
  <div>$codBadge</div>

  <div class="grid">
    <div class="box">
      <strong>Consignee (Customer)</strong>
      $buyerNameEscaped<br>
      $buyerContactEscaped
    </div>
    <div class="box">
      <strong>Courier (Rider)</strong>
      $courierNameEscaped<br>
      $courierContactEscaped
    </div>
    <div class="box wide">
      <strong>Shipper & Pickup Location</strong>
      $sellerNameEscaped<br>
      $pickupAddressEscaped<br>
      ${pickupContactEscaped.isNotEmpty ? 'Contact: $pickupContactEscaped' : ''}
    </div>
    <div class="box wide">
      <strong>Destination Address</strong>
      $deliveryAddressEscaped<br>
      Contact: $buyerContactEscaped
    </div>
    <div class="box">
      <strong>Schedule / Order Date</strong>
      $scheduleEscaped
    </div>
    <div class="box">
      <strong>Payment Details</strong>
      $paymentMethodEscaped &middot; $paymentStatusEscaped<br>
      Total: $totalFormatted
    </div>
    $instructionsHtml
  </div>

  <table>
    <thead>
      <tr>
        <th>Item Description</th>
        <th class="quantity">Qty</th>
        <th class="price">Unit Price</th>
        <th class="price">Amount</th>
      </tr>
    </thead>
    <tbody>
      $itemRows
    </tbody>
  </table>

  <div class="totals">Total: $totalFormatted</div>

  <div class="footer">
    AgriSell Delivery Network &middot; Keep this waybill attached to the produce package &middot; Generated $scheduleEscaped
  </div>

  <script>window.addEventListener('load',()=>{window.print();});</script>
</body>
</html>''';
}
