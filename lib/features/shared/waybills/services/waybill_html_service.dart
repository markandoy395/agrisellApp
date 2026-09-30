import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';

class WaybillHtmlService {
  const WaybillHtmlService();

  static String escape(Object? value) {
    if (value == null) return '';
    return value
        .toString()
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }

  static String formatCurrency(double amount) {
    return 'PHP ${amount.toStringAsFixed(2)}';
  }

  static String generateHtml(DeliveryWaybill waybill) {
    final orderIdEscaped = escape(waybill.orderId);
    final waybillNumberEscaped = escape(waybill.waybillNumber);
    final buyerNameEscaped = escape(waybill.buyerName);
    final buyerContactEscaped = escape(waybill.buyerContact);
    final deliveryAddressEscaped = escape(waybill.deliveryAddress);
    final sellerNameEscaped = escape(waybill.sellerName);
    final pickupAddressEscaped = escape(waybill.pickupAddress);
    final pickupContactEscaped = escape(waybill.pickupContact);
    final courierNameEscaped = escape(waybill.courierName);
    final courierContactEscaped = escape(waybill.courierContact);
    final scheduleEscaped = escape(waybill.schedule);
    final paymentMethodEscaped = escape(waybill.paymentMethod);
    final paymentStatusEscaped = escape(waybill.paymentStatus);
    final totalFormatted = formatCurrency(waybill.totalAmount);
    final codFormatted = formatCurrency(waybill.codAmount);

    final itemRows = waybill.items.map((item) {
      return '<tr>'
          '<td>${escape(item.name)}</td>'
          '<td style="text-align:center;">${escape(item.quantityDescription)}</td>'
          '<td style="text-align:right;">${formatCurrency(item.unitPrice)}</td>'
          '<td style="text-align:right; font-weight:600;">${formatCurrency(item.total)}</td>'
          '</tr>';
    }).join('\n');

    final instructionsHtml = waybill.instructions != null &&
            waybill.instructions!.isNotEmpty
        ? '<div class="box wide"><strong>Instructions & Handling</strong>${escape(waybill.instructions)}</div>'
        : '';

    final codBadge = waybill.isCod
        ? '<span class="badge badge-cod">COLLECT COD: $codFormatted</span>'
        : '<span class="badge">PREPAID</span>';

    return '''<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Waybill $waybillNumberEscaped</title>
  <style>
    body { font: 14px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; margin: 32px; color: #17231b; }
    h1 { margin: 0 0 2px; font-size: 22px; color: #0F743B; font-weight: 800; }
    .subhead { font-size: 12px; color: #607064; margin-bottom: 12px; text-transform: uppercase; letter-spacing: 0.5px; }
    .id { font-size: 20px; font-weight: 700; color: #0B0B0B; }
    .barcode { font-family: monospace; font-size: 18px; letter-spacing: 5px; background: #EEF7E0; padding: 6px 14px; display: inline-block; border-radius: 6px; margin: 8px 0 16px; border: 1px dashed #0F743B; }
    .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 14px; }
    .box { border: 1px solid #b8c4ba; border-radius: 8px; padding: 12px 14px; background: #fafcfa; font-size: 13px; line-height: 1.4; }
    .wide { grid-column: 1 / -1; }
    .box strong { display: block; font-size: 11px; text-transform: uppercase; color: #607064; margin-bottom: 4px; letter-spacing: 0.5px; }
    table { width: 100%; border-collapse: collapse; margin-top: 14px; }
    th, td { text-align: left; padding: 7px 10px; border-bottom: 1px solid #e2e8e3; font-size: 13px; }
    th { background: #E5F0E9; color: #0F743B; font-weight: 700; font-size: 11px; text-transform: uppercase; }
    .badge { display: inline-block; padding: 4px 10px; border-radius: 999px; font-size: 11px; font-weight: 800; text-transform: uppercase; background: #E5F0E9; color: #0F743B; }
    .badge-cod { background: #FFF3E0; color: #A15D13; }
    .totals { margin-top: 12px; text-align: right; font-size: 16px; font-weight: 800; color: #0F743B; }
    .footer { margin-top: 28px; padding-top: 12px; border-top: 1px dashed #b8c4ba; font-size: 11px; color: #77817D; text-align: center; }
    @media print {
      body { margin: 10mm; }
    }
  </style>
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
        <th style="text-align:center;">Qty</th>
        <th style="text-align:right;">Unit Price</th>
        <th style="text-align:right;">Amount</th>
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

  static Future<bool> openPrintableWaybill(DeliveryWaybill waybill) async {
    final html = generateHtml(waybill);
    final uri = Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: utf8,
    );
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      final file = await saveWaybillHtml(waybill);
      return await launchUrl(
        Uri.file(file.path),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  static Future<File> saveWaybillHtml(DeliveryWaybill waybill) async {
    final html = generateHtml(waybill);
    final dir = await getTemporaryDirectory();
    final sanitizedId = waybill.orderId.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final file = File('${dir.path}/waybill_$sanitizedId.html');
    return await file.writeAsString(html, flush: true);
  }

  static String formatPlainText(DeliveryWaybill waybill) {
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
      buffer.writeln(' - ${item.name} (${item.quantityDescription}): ${formatCurrency(item.total)}');
    }
    buffer.writeln('---------------------------------');
    buffer.writeln('PAYMENT: ${waybill.paymentMethod} (${waybill.paymentStatus})');
    if (waybill.isCod) {
      buffer.writeln('COLLECT COD: ${formatCurrency(waybill.codAmount)}');
    }
    buffer.writeln('TOTAL: ${formatCurrency(waybill.totalAmount)}');
    if (waybill.instructions != null && waybill.instructions!.isNotEmpty) {
      buffer.writeln('INSTRUCTIONS: ${waybill.instructions}');
    }
    buffer.writeln('=================================');
    return buffer.toString();
  }
}
