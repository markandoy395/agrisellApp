import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_restock.dart';
import '../controllers/farmer_restock_controller.dart';
import '../styles/farmer_restock_dialog_styles.dart';
import 'farmer_restock_lot_fields.dart';
import 'farmer_restock_stock_summary.dart';

class FarmerRestockForm extends StatelessWidget {
  const FarmerRestockForm({
    required this.product,
    required this.controller,
    super.key,
  });

  final FarmerDashboardProduct product;
  final FarmerRestockController controller;

  @override
  Widget build(BuildContext context) => Form(
    key: controller.formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FarmerRestockStockSummary(
          currentStock: product.availableQuantity,
          resultingStock: controller.resultingStock(product.availableQuantity),
          unit: product.unitType,
        ),
        FarmerRestockDialogStyles.spacingSummary,
        const Text(
          'Quantity to add',
          style: FarmerRestockDialogStyles.fieldLabelStyle,
        ),
        FarmerRestockDialogStyles.spacingQuantityLabel,
        TextFormField(
          key: const Key('restock-quantity-field'),
          controller: controller.quantityController,
          style: FarmerRestockDialogStyles.inputTextStyle,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d{0,7}(?:\.\d{0,3})?'),
            ),
          ],
          validator: (value) => FarmerRestockRules.validate(
            value,
            currentStock: product.availableQuantity,
          ),
          decoration: FarmerRestockDialogStyles.quantityDecoration(
            unit: product.unitType,
          ),
        ),
        FarmerRestockDialogStyles.spacingField,
        FarmerRestockLotFields(
          dateType: controller.dateType,
          allowedDateTypes: controller.allowedDateTypes,
          harvestedAt: controller.harvestedAt,
          marketableUntil: controller.marketableUntil,
          lotCodeController: controller.lotCodeController,
          storageController: controller.storageController,
          errors: controller.lotErrors,
          onDateTypeChanged: controller.setDateType,
          onSelectHarvestDate: () => controller.pickHarvestDate(context),
          onSelectMarketableUntil: () =>
              controller.pickMarketableUntil(context),
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 12),
          title: const Text(
            'Add a restock note (optional)',
            style: FarmerRestockDialogStyles.noteLabelStyle,
          ),
          children: [
            TextField(
              key: const Key('restock-reason-field'),
              controller: controller.reasonController,
              maxLength: 240,
              maxLines: 2,
              decoration: FarmerRestockDialogStyles.notesDecoration,
            ),
          ],
        ),
      ],
    ),
  );
}
