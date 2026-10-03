import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';
import 'package:agresell_app/features/shared/waybills/presentation/styles/delivery_waybill_styles.dart';
import 'package:agresell_app/features/shared/waybills/presentation/widgets/waybill_info_box.dart';
import 'package:agresell_app/features/shared/waybills/services/waybill_html_service.dart';

/// Renders the printable waybill card containing customer, courier, routing,
/// package items, and total pricing info.
class WaybillPreviewCard extends StatelessWidget {
  const WaybillPreviewCard({
    required this.waybill,
    super.key,
  });

  final DeliveryWaybill waybill;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('waybill-preview-card'),
    padding: DeliveryWaybillStyles.previewPadding,
    decoration: DeliveryWaybillStyles.previewCardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(),
        const SizedBox(height: 10),
        _buildBarcode(),
        const SizedBox(height: 14),
        ..._buildInfoBoxes(),
        const SizedBox(height: 14),
        _buildPackageItemsSection(),
        const Divider(height: 16, color: AgrisellColors.borderLine),
        _buildTotalRow(),
      ],
    ),
  );

  Widget _buildHeaderRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            waybill.waybillNumber,
            style: DeliveryWaybillStyles.waybillNumber,
          ),
          Text(
            'Order ORD-${waybill.orderId}',
            style: DeliveryWaybillStyles.orderNumber,
          ),
        ],
      ),
      Container(
        padding: DeliveryWaybillStyles.badgePadding,
        decoration: DeliveryWaybillStyles.badgeDecoration(
          isCod: waybill.isCod,
        ),
        child: Text(
          waybill.isCod ? 'CASH ON DELIVERY' : 'PREPAID',
          style: DeliveryWaybillStyles.badgeTextStyle(
            isCod: waybill.isCod,
          ),
        ),
      ),
    ],
  );

  Widget _buildBarcode() => Container(
    width: double.infinity,
    padding: DeliveryWaybillStyles.barcodePadding,
    decoration: DeliveryWaybillStyles.barcodeDecoration,
    child: const Center(
      child: Text(
        '||| | |||| || | |||| |||||',
        style: DeliveryWaybillStyles.barcodeText,
      ),
    ),
  );

  List<Widget> _buildInfoBoxes() => [
    WaybillInfoBox(
      title: 'Consignee (Customer)',
      icon: Icons.person_outline_rounded,
      lines: [waybill.buyerName, waybill.buyerContact],
    ),
    const SizedBox(height: 8),
    WaybillInfoBox(
      title: 'Courier (Rider)',
      icon: Icons.delivery_dining_outlined,
      lines: [
        waybill.courierName,
        if (waybill.courierContact.isNotEmpty) waybill.courierContact,
      ],
    ),
    const SizedBox(height: 8),
    WaybillInfoBox(
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
    WaybillInfoBox(
      title: 'Destination',
      icon: Icons.place_outlined,
      lines: [waybill.deliveryAddress],
    ),
    const SizedBox(height: 8),
    WaybillInfoBox(
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
      WaybillInfoBox(
        title: 'Handling & Instructions',
        icon: Icons.info_outline_rounded,
        lines: [waybill.instructions!],
      ),
    ],
  ];

  Widget _buildPackageItemsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'PACKAGE ITEMS',
        style: DeliveryWaybillStyles.packageItemsHeading,
      ),
      const SizedBox(height: 6),
      ...waybill.items.map((item) => Padding(
        padding: DeliveryWaybillStyles.itemRowPadding,
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${item.name} (${item.quantityDescription})',
                style: DeliveryWaybillStyles.itemName,
              ),
            ),
            Text(
              WaybillHtmlService.formatCurrency(item.total),
              style: DeliveryWaybillStyles.itemTotal,
            ),
          ],
        ),
      )),
    ],
  );

  Widget _buildTotalRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text(
        'Total Amount',
        style: DeliveryWaybillStyles.totalAmountLabel,
      ),
      Text(
        WaybillHtmlService.formatCurrency(waybill.totalAmount),
        style: DeliveryWaybillStyles.totalAmountValue,
      ),
    ],
  );
}
