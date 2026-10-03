import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_restock.dart';
import '../controllers/farmer_restock_controller.dart';
import '../styles/farmer_restock_dialog_styles.dart';
import 'farmer_restock_header.dart';
import 'farmer_restock_lot_fields.dart';
import 'farmer_restock_stock_summary.dart';

Future<FarmerRestockRequest?> showFarmerRestockDialog(
  BuildContext context, {
  required FarmerDashboardProduct product,
}) => showDialog<FarmerRestockRequest>(
  context: context,
  builder: (_) => FarmerRestockDialog(product: product),
);

class FarmerRestockDialog extends StatefulWidget {
  const FarmerRestockDialog({required this.product, super.key});

  final FarmerDashboardProduct product;

  @override
  State<FarmerRestockDialog> createState() => _FarmerRestockDialogState();
}

class _FarmerRestockDialogState extends State<FarmerRestockDialog> {
  late final FarmerRestockController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FarmerRestockController(product: widget.product);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final request = _controller.submit();
    if (request != null && mounted) {
      Navigator.of(context).pop(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => AlertDialog(
        backgroundColor: FarmerRestockDialogStyles.dialogBackground,
        shape: FarmerRestockDialogStyles.dialogShape,
        titlePadding: FarmerRestockDialogStyles.dialogTitlePadding,
        contentPadding: FarmerRestockDialogStyles.dialogContentPadding,
        actionsPadding: FarmerRestockDialogStyles.dialogActionsPadding,
        title: FarmerRestockHeader(productName: product.name),
        content: Form(
          key: _controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FarmerRestockStockSummary(
                  currentStock: product.availableQuantity,
                  resultingStock: _controller.resultingStock(
                    product.availableQuantity,
                  ),
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
                  controller: _controller.quantityController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                  dateType: _controller.dateType,
                  allowedDateTypes: _controller.allowedDateTypes,
                  harvestedAt: _controller.harvestedAt,
                  marketableUntil: _controller.marketableUntil,
                  lotCodeController: _controller.lotCodeController,
                  storageController: _controller.storageController,
                  errors: _controller.lotErrors,
                  onDateTypeChanged: _controller.setDateType,
                  onSelectHarvestDate: () =>
                      _controller.pickHarvestDate(context),
                  onSelectMarketableUntil: () =>
                      _controller.pickMarketableUntil(context),
                ),
                FarmerRestockDialogStyles.spacingField,
                TextField(
                  key: const Key('restock-reason-field'),
                  controller: _controller.reasonController,
                  maxLength: 240,
                  maxLines: 2,
                  decoration: FarmerRestockDialogStyles.notesDecoration,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm-restock-button'),
            onPressed: _handleSubmit,
            style: FarmerRestockDialogStyles.confirmButtonStyle,
            child: const Text('Confirm restock'),
          ),
        ],
      ),
    );
  }
}
