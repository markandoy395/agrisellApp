import 'package:flutter/material.dart';
import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import 'package:agresell_app/features/farmer/discounts/presentation/controllers/farmer_discount_form_calculations.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';

/// Owns promotion inputs, selection, validation, previews, and persistence.
class FarmerDiscountFormController extends ChangeNotifier {
  FarmerDiscountFormController({
    required this.farmId,
    required this.repository,
    this.existingDiscount,
    FarmerDashboardProduct? initialProduct,
    List<FarmerDashboardProduct> availableProducts = const [],
  }) {
    final existing = existingDiscount;

    nameController = TextEditingController(text: existing?.name ?? '');
    valueController = TextEditingController(
      text: existing != null ? existing.discountValue.toString() : '',
    );
    promoCodeController = TextEditingController(
      text: existing?.promoCode ?? '',
    );

    discountType = existing?.discountType ?? 'percentage';
    startsAt = existing?.startsAt;
    endsAt = existing?.endsAt;

    if (existing != null) {
      selectedCommodityIds = existing.commodityIds.toSet();
    } else if (initialProduct?.commodityId != null) {
      selectedCommodityIds = {initialProduct!.commodityId!};
    } else {
      selectedCommodityIds = {};
    }
    products = availableProducts.isNotEmpty
        ? availableProducts
        : initialProduct != null
        ? [initialProduct]
        : [];
    valueController.addListener(notifyListeners);
  }

  final int farmId;
  final FarmerDiscountRepository repository;
  final FarmerDiscount? existingDiscount;
  late final List<FarmerDashboardProduct> products;
  late final TextEditingController nameController;
  late final TextEditingController valueController;
  late final TextEditingController promoCodeController;
  late String discountType;
  DateTime? startsAt;
  DateTime? endsAt;
  late Set<int> selectedCommodityIds;
  bool isSaving = false;
  String? errorMessage;
  bool _disposed = false;

  bool get isEditing => existingDiscount != null;
  bool get allProductsSelected =>
      selectedCommodityIds.length == products.length;

  void setDiscountType(String type) {
    discountType = type;
    notifyListeners();
  }

  void setStartDate(DateTime date) {
    startsAt = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endsAt = date;
    notifyListeners();
  }

  void toggleAllProducts() {
    if (allProductsSelected) {
      selectedCommodityIds.clear();
    } else {
      selectedCommodityIds = products
          .map((p) => p.commodityId)
          .whereType<int>()
          .toSet();
    }
    notifyListeners();
  }

  void selectProduct(int id, bool selected) {
    if (selected) {
      selectedCommodityIds.add(id);
    } else {
      selectedCommodityIds.remove(id);
    }
    notifyListeners();
  }

  String previewPrice(FarmerDashboardProduct product) =>
      FarmerDiscountFormCalculations.previewPrice(
        product: product,
        valueText: valueController.text,
        discountType: discountType,
      );

  Future<FarmerDiscount?> save() async {
    if (isSaving) return null;
    final name = nameController.text.trim();
    final value = double.tryParse(valueController.text.trim());

    final validationError =
        FarmerDiscountFormCalculations.validateDiscountForm(
          name: name,
          value: value,
          discountType: discountType,
          startsAt: startsAt,
          endsAt: endsAt,
          selectedCommodityIds: selectedCommodityIds,
        );
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return null;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final promoCode = promoCodeController.text.trim().isEmpty
          ? null
          : promoCodeController.text.trim().toUpperCase();

      var saleId = existingDiscount?.saleId;
      if (saleId != null) {
        await repository.updateDiscount(
          saleId: saleId,
          farmId: farmId,
          name: name,
          discountType: discountType,
          discountValue: value!,
          startsAt: startsAt,
          endsAt: endsAt,
          promoCode: promoCode,
          commodityIds: selectedCommodityIds.toList(growable: false),
        );
      } else {
        saleId = await repository.createDiscount(
          farmId: farmId,
          name: name,
          discountType: discountType,
          discountValue: value!,
          startsAt: startsAt,
          endsAt: endsAt,
          promoCode: promoCode,
          commodityIds: selectedCommodityIds.toList(growable: false),
        );
      }
      if (_disposed) return null;
      return FarmerDiscount(
        saleId: saleId,
        farmId: farmId,
        name: name,
        discountType: discountType,
        discountValue: value,
        startsAt: startsAt,
        endsAt: endsAt,
        promoCode: promoCode,
        commodityIds: selectedCommodityIds.toList(growable: false),
      );
    } catch (_) {
      if (_disposed) return null;
      errorMessage = 'Failed to save discount. Please try again.';
      isSaving = false;
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    valueController.removeListener(notifyListeners);
    nameController.dispose();
    valueController.dispose();
    promoCodeController.dispose();
    super.dispose();
  }
}
