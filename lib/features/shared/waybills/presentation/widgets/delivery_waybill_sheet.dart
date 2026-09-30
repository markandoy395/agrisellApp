import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';
import 'package:agresell_app/features/shared/waybills/services/waybill_html_service.dart';

Future<void> showDeliveryWaybillSheet(
  BuildContext context,
  DeliveryWaybill waybill,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DeliveryWaybillSheet(waybill: waybill),
  );
}

class DeliveryWaybillSheet extends StatelessWidget {
  const DeliveryWaybillSheet({required this.waybill, super.key});

  final DeliveryWaybill waybill;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      constraints: BoxConstraints(maxHeight: size.height * 0.9),
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(context),
            const Divider(height: 1, color: AgrisellColors.borderLine),
            Flexible(
              child: SingleChildScrollView(
                key: const Key('waybill-sheet-scroll'),
                padding: const EdgeInsets.all(16),
                child: _buildWaybillPreview(context),
              ),
            ),
            const Divider(height: 1, color: AgrisellColors.borderLine),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() => Container(
    margin: const EdgeInsets.only(top: 10, bottom: 4),
    width: 38,
    height: 4,
    decoration: BoxDecoration(
      color: AgrisellColors.borderLine,
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        const Icon(
          Icons.receipt_long_rounded,
          color: AgrisellColors.authGreen,
          size: 22,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Waybill',
                style: TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Printable package receipt & courier slip',
                style: TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          key: const Key('waybill-close-button'),
          icon: const Icon(Icons.close_rounded, color: AgrisellColors.mutedText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  Widget _buildWaybillPreview(BuildContext context) => Container(
    key: const Key('waybill-preview-card'),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AgrisellColors.pageBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AgrisellColors.borderLine, width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  waybill.waybillNumber,
                  style: const TextStyle(
                    color: AgrisellColors.brandBlack,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Order ORD-${waybill.orderId}',
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: waybill.isCod
                    ? AgrisellColors.statusOrangeBackground
                    : AgrisellColors.forestSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                waybill.isCod ? 'CASH ON DELIVERY' : 'PREPAID',
                style: TextStyle(
                  color: waybill.isCod
                      ? AgrisellColors.statusOrangeText
                      : AgrisellColors.forestGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AgrisellColors.limeSoft,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AgrisellColors.forestGreen.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: const Center(
            child: Text(
              '||| | |||| || | |||| |||||',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: AgrisellColors.forestGreen,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _buildInfoBox(
          title: 'Consignee (Customer)',
          icon: Icons.person_outline_rounded,
          lines: [waybill.buyerName, waybill.buyerContact],
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          title: 'Courier (Rider)',
          icon: Icons.delivery_dining_outlined,
          lines: [
            waybill.courierName,
            if (waybill.courierContact.isNotEmpty) waybill.courierContact,
          ],
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          title: 'Shipper & Pickup',
          icon: Icons.storefront_outlined,
          lines: [
            waybill.sellerName,
            waybill.pickupAddress,
            if (waybill.pickupContact.isNotEmpty)
              'Contact: ${waybill.pickupContact}',
          ],
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          title: 'Destination',
          icon: Icons.place_outlined,
          lines: [waybill.deliveryAddress],
        ),
        const SizedBox(height: 8),
        _buildInfoBox(
          title: 'Schedule & Payment',
          icon: Icons.calendar_today_outlined,
          lines: [
            'Schedule: ${waybill.schedule}',
            'Payment: ${waybill.paymentMethod} (${waybill.paymentStatus})',
            if (waybill.isCod)
              'Collect COD: ${WaybillHtmlService.formatCurrency(waybill.codAmount)}',
          ],
        ),
        if (waybill.instructions != null &&
            waybill.instructions!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildInfoBox(
            title: 'Handling & Instructions',
            icon: Icons.info_outline_rounded,
            lines: [waybill.instructions!],
          ),
        ],
        const SizedBox(height: 14),
        const Text(
          'PACKAGE ITEMS',
          style: TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        ...waybill.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} (${item.quantityDescription})',
                      style: const TextStyle(
                        color: AgrisellColors.brandBlack,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    WaybillHtmlService.formatCurrency(item.total),
                    style: const TextStyle(
                      color: AgrisellColors.brandBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )),
        const Divider(height: 16, color: AgrisellColors.borderLine),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount',
              style: TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              WaybillHtmlService.formatCurrency(waybill.totalAmount),
              style: const TextStyle(
                color: AgrisellColors.forestGreen,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildInfoBox({
    required String title,
    required IconData icon,
    required List<String> lines,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AgrisellColors.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AgrisellColors.borderLine),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AgrisellColors.authGreen),
            const SizedBox(width: 4),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...lines.map((line) => Text(
              line,
              style: const TextStyle(
                color: AgrisellColors.brandBlack,
                fontSize: 12,
                height: 1.25,
              ),
            )),
      ],
    ),
  );

  Widget _buildActionButtons(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            key: const Key('waybill-print-button'),
            onPressed: () => _printWaybill(context),
            icon: const Icon(Icons.print_rounded, size: 18),
            label: const Text(
              'Print Waybill',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AgrisellColors.authGreen,
              foregroundColor: AgrisellColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  key: const Key('waybill-download-button'),
                  onPressed: () => _downloadWaybill(context),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text(
                    'Save HTML',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AgrisellColors.authGreen,
                    side: const BorderSide(color: AgrisellColors.borderLine),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  key: const Key('waybill-copy-button'),
                  onPressed: () => _copyWaybill(context),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text(
                    'Copy Text',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AgrisellColors.authGreen,
                    side: const BorderSide(color: AgrisellColors.borderLine),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _printWaybill(BuildContext context) async {
    try {
      await WaybillHtmlService.openPrintableWaybill(waybill);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open print dialog: $e')),
        );
      }
    }
  }

  Future<void> _downloadWaybill(BuildContext context) async {
    try {
      final file = await WaybillHtmlService.saveWaybillHtml(waybill);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Waybill saved to ${file.path}'),
            backgroundColor: AgrisellColors.forestGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save waybill: $e')),
        );
      }
    }
  }

  Future<void> _copyWaybill(BuildContext context) async {
    final text = WaybillHtmlService.formatPlainText(waybill);
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waybill details copied to clipboard'),
          backgroundColor: AgrisellColors.forestGreen,
        ),
      );
    }
  }
}
