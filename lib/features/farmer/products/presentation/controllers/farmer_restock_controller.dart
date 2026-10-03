import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_restock.dart';
import 'package:agresell_app/features/shared/products/domain/product_availability_date_rules.dart';
import 'package:agresell_app/features/shared/products/domain/product_categories.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';

class FarmerRestockController extends ChangeNotifier {
  FarmerRestockController({required this.product}) {
    _dateType = product.inventoryDateType;
    _harvestedAt = ProductAvailabilityDateRules.philippineToday();
    quantityController.addListener(notifyListeners);
  }

  final FarmerDashboardProduct product;
  final formKey = GlobalKey<FormState>();
  final quantityController = TextEditingController();
  final reasonController = TextEditingController();
  final lotCodeController = TextEditingController();
  final storageController = TextEditingController();

  late ProductInventoryDateType _dateType;
  DateTime? _harvestedAt;
  DateTime? _marketableUntil;
  Map<String, String> _lotErrors = const {};

  ProductInventoryDateType get dateType => _dateType;
  DateTime? get harvestedAt => _harvestedAt;
  DateTime? get marketableUntil => _marketableUntil;
  Map<String, String> get lotErrors => _lotErrors;

  double resultingStock(double currentStock) {
    final quantity = double.tryParse(quantityController.text.trim());
    return quantity == null || quantity <= 0
        ? currentStock
        : currentStock + quantity;
  }

  List<ProductInventoryDateType> get allowedDateTypes {
    if (product.category == ProductCategories.fruitTrees) {
      return const [ProductInventoryDateType.nonPerishable];
    }
    if (ProductCategories.values.contains(product.category)) {
      return const [
        ProductInventoryDateType.freshProduce,
        ProductInventoryDateType.packagedFood,
      ];
    }
    return ProductInventoryDateType.values;
  }

  ProductInventoryLotDraft get inventoryLot => ProductInventoryLotDraft(
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
    lotCode: lotCodeController.text.trim().isEmpty
        ? null
        : lotCodeController.text.trim(),
    storageInstructions: storageController.text.trim().isEmpty
        ? null
        : storageController.text.trim(),
  );

  void setDateType(ProductInventoryDateType? value) {
    if (value == null) return;
    _dateType = value;
    _marketableUntil = null;
    _lotErrors = const {};
    notifyListeners();
  }

  Future<void> pickHarvestDate(BuildContext context) async {
    final today = ProductAvailabilityDateRules.philippineToday();
    final selected = await showDatePicker(
      context: context,
      initialDate: _harvestedAt ?? today,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
      currentDate: today,
      helpText: 'Harvest or production date',
    );
    if (!context.mounted || selected == null) return;

    _harvestedAt = selected;
    if (_marketableUntil != null && _marketableUntil!.isBefore(selected)) {
      _marketableUntil = null;
    }
    _lotErrors = Map.of(_lotErrors)..remove('harvestedAt');
    notifyListeners();
  }

  Future<void> pickMarketableUntil(BuildContext context) async {
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
    if (!context.mounted || selected == null) return;

    _marketableUntil = selected;
    _lotErrors = Map.of(_lotErrors)
      ..remove('sellUntil')
      ..remove('expiresAt');
    notifyListeners();
  }

  FarmerRestockRequest? submit() {
    if (!(formKey.currentState?.validate() ?? false)) return null;

    final lot = inventoryLot;
    final lotErrors = lot.validationErrors(
      today: ProductAvailabilityDateRules.philippineToday(),
    );
    if (lotErrors.isNotEmpty) {
      _lotErrors = lotErrors;
      notifyListeners();
      return null;
    }

    final reason = reasonController.text.trim();
    return FarmerRestockRequest(
      quantity: FarmerRestockRules.parse(quantityController.text),
      inventoryLot: lot,
      reason: reason.isEmpty ? null : reason,
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    reasonController.dispose();
    lotCodeController.dispose();
    storageController.dispose();
    super.dispose();
  }
}
