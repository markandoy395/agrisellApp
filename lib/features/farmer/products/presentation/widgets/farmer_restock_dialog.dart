import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_restock.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/farmer_restock_lot_fields.dart';
import 'package:agresell_app/features/shared/products/domain/product_availability_date_rules.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';
import 'package:agresell_app/features/shared/products/domain/product_categories.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  final _lotCodeController = TextEditingController();
  final _storageController = TextEditingController();
  late ProductInventoryDateType _dateType;
  DateTime? _harvestedAt;
  DateTime? _marketableUntil;
  Map<String, String> _lotErrors = const {};

  @override
  void initState() {
    super.initState();
    _dateType = widget.product.inventoryDateType;
    _harvestedAt = ProductAvailabilityDateRules.philippineToday();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    _lotCodeController.dispose();
    _storageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final currentStock = product.availableQuantity;
    final quantity = double.tryParse(_quantityController.text.trim());
    final resultingStock = quantity == null || quantity <= 0
        ? currentStock
        : currentStock + quantity;

    return AlertDialog(
      backgroundColor: AgrisellColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 4),
      actionsPadding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AgrisellColors.forestSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AgrisellColors.authGreen,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add stock',
                  style: TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StockSummary(
                currentStock: currentStock,
                resultingStock: resultingStock,
                unit: product.unitType,
              ),
              const SizedBox(height: 16),
              const Text(
                'Quantity to add',
                style: TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              TextFormField(
                key: const Key('restock-quantity-field'),
                controller: _quantityController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d{0,7}(?:\.\d{0,3})?'),
                  ),
                ],
                onChanged: (_) => setState(() {}),
                validator: (value) => FarmerRestockRules.validate(
                  value,
                  currentStock: currentStock,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: product.unitType,
                  filled: true,
                  fillColor: AgrisellColors.searchBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AgrisellColors.authGreen,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              FarmerRestockLotFields(
                dateType: _dateType,
                allowedDateTypes: _allowedDateTypes,
                harvestedAt: _harvestedAt,
                marketableUntil: _marketableUntil,
                lotCodeController: _lotCodeController,
                storageController: _storageController,
                errors: _lotErrors,
                onDateTypeChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _dateType = value;
                    _marketableUntil = null;
                    _lotErrors = const {};
                  });
                },
                onSelectHarvestDate: _pickHarvestDate,
                onSelectMarketableUntil: _pickMarketableUntil,
              ),
              const SizedBox(height: 13),
              TextField(
                key: const Key('restock-reason-field'),
                controller: _reasonController,
                maxLength: 240,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Example: New supplier delivery',
                  filled: true,
                  fillColor: AgrisellColors.searchBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
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
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AgrisellColors.authGreen,
            foregroundColor: AgrisellColors.surface,
          ),
          child: const Text('Confirm restock'),
        ),
      ],
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final lot = _inventoryLot;
    final lotErrors = lot.validationErrors(
      today: ProductAvailabilityDateRules.philippineToday(),
    );
    if (lotErrors.isNotEmpty) {
      setState(() => _lotErrors = lotErrors);
      return;
    }
    final reason = _reasonController.text.trim();
    Navigator.of(context).pop(
      FarmerRestockRequest(
        quantity: FarmerRestockRules.parse(_quantityController.text),
        inventoryLot: lot,
        reason: reason.isEmpty ? null : reason,
      ),
    );
  }

  ProductInventoryLotDraft get _inventoryLot => ProductInventoryLotDraft(
    dateType: _dateType,
    harvestedAt: _dateType == ProductInventoryDateType.nonPerishable
        ? null
        : _harvestedAt,
    sellUntil: _dateType == ProductInventoryDateType.freshProduce
        ? _marketableUntil
        : null,
    expiresAt: _dateType == ProductInventoryDateType.packagedFood
        ? _marketableUntil
        : null,
    lotCode: _lotCodeController.text.trim().isEmpty
        ? null
        : _lotCodeController.text.trim(),
    storageInstructions: _storageController.text.trim().isEmpty
        ? null
        : _storageController.text.trim(),
  );

  List<ProductInventoryDateType> get _allowedDateTypes {
    if (widget.product.category == ProductCategories.fruitTrees) {
      return const [ProductInventoryDateType.nonPerishable];
    }
    if (ProductCategories.values.contains(widget.product.category)) {
      return const [
        ProductInventoryDateType.freshProduce,
        ProductInventoryDateType.packagedFood,
      ];
    }
    return ProductInventoryDateType.values;
  }

  Future<void> _pickHarvestDate() async {
    final today = ProductAvailabilityDateRules.philippineToday();
    final selected = await showDatePicker(
      context: context,
      initialDate: _harvestedAt ?? today,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
      currentDate: today,
      helpText: 'Harvest or production date',
    );
    if (!mounted || selected == null) return;
    setState(() {
      _harvestedAt = selected;
      if (_marketableUntil != null && _marketableUntil!.isBefore(selected)) {
        _marketableUntil = null;
      }
      _lotErrors = Map.of(_lotErrors)..remove('harvestedAt');
    });
  }

  Future<void> _pickMarketableUntil() async {
    final today = ProductAvailabilityDateRules.philippineToday();
    final firstDate = _harvestedAt != null && _harvestedAt!.isAfter(today)
        ? _harvestedAt!
        : today;
    final selected = await showDatePicker(
      context: context,
      initialDate: _marketableUntil ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime(firstDate.year + 10, firstDate.month, firstDate.day),
      currentDate: today,
      helpText: _dateType == ProductInventoryDateType.packagedFood
          ? 'Printed expiration date'
          : 'Final selling date',
    );
    if (!mounted || selected == null) return;
    setState(() {
      _marketableUntil = selected;
      _lotErrors = Map.of(_lotErrors)
        ..remove('sellUntil')
        ..remove('expiresAt');
    });
  }
}

class _StockSummary extends StatelessWidget {
  const _StockSummary({
    required this.currentStock,
    required this.resultingStock,
    required this.unit,
  });

  final double currentStock;
  final double resultingStock;
  final String unit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AgrisellColors.limeSoft,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(child: _value('Current stock', currentStock)),
        const Icon(
          Icons.arrow_forward_rounded,
          color: AgrisellColors.authGreen,
          size: 20,
        ),
        Expanded(
          child: _value('After restock', resultingStock, alignEnd: true),
        ),
      ],
    ),
  );

  Widget _value(String label, double value, {bool alignEnd = false}) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AgrisellColors.mutedText,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        '${_format(value)} $unit',
        style: const TextStyle(
          color: AgrisellColors.headingGreen,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  String _format(double value) => value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '');
}
