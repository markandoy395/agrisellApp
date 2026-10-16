import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';
import 'package:agresell_app/features/shared/waybills/services/waybill_html_service.dart';

/// Encapsulates user actions for printing, downloading, and copying waybill data.
abstract final class WaybillSheetActions {
  static Future<void> printWaybill(
    BuildContext context,
    DeliveryWaybill waybill,
  ) async {
    try {
      final opened = await WaybillHtmlService.openPrintableWaybill(waybill);
      if (!opened && context.mounted) {
        _printUnavailable(context);
      }
    } catch (_) {
      if (context.mounted) {
        _printUnavailable(context);
      }
    }
  }

  static void _printUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showAppSnackBar(
      const SnackBar(
        content: Text(
          'Could not open the print dialog. Close the waybill and try again.',
        ),
      ),
    );
  }

  static Future<void> downloadWaybill(
    BuildContext context,
    DeliveryWaybill waybill,
  ) async {
    try {
      final file = await WaybillHtmlService.saveWaybillHtml(waybill);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showAppSnackBar(
          SnackBar(
            content: Text('Waybill saved to ${file.path}'),
            backgroundColor: AgrisellColors.forestGreen,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showAppSnackBar(
          const SnackBar(
            content: Text('Could not save the waybill. Try again.'),
          ),
        );
      }
    }
  }

  static Future<void> copyWaybill(
    BuildContext context,
    DeliveryWaybill waybill,
  ) async {
    final text = WaybillHtmlService.formatPlainText(waybill);
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(
          content: Text('Waybill details copied to clipboard'),
          backgroundColor: AgrisellColors.forestGreen,
        ),
      );
    }
  }
}
