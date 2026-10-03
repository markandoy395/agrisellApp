import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';
import 'package:agresell_app/features/shared/waybills/services/waybill_html_template.dart';
import 'package:agresell_app/features/shared/waybills/services/waybill_text_formatter.dart';

class WaybillHtmlService {
  const WaybillHtmlService();

  static String escape(Object? value) => escapeHtml(value);

  static String formatCurrency(double amount) => formatWaybillCurrency(amount);

  static String generateHtml(DeliveryWaybill waybill) =>
      buildWaybillHtml(waybill);

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
    final sanitizedId =
        waybill.orderId.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final file = File('${dir.path}/waybill_$sanitizedId.html');
    return await file.writeAsString(html, flush: true);
  }

  static String formatPlainText(DeliveryWaybill waybill) =>
      formatWaybillPlainText(waybill);
}
