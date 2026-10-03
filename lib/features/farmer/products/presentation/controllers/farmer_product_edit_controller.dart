import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/product_edit_options.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/farmer_product_edit_builder.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_form_message.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_image_picker.dart';
import 'package:agresell_app/features/farmer/products/presentation/utils/farmer_product_discount_coordinator.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

class FarmerProductEditController extends ChangeNotifier {
  FarmerProductEditController({
    required this.product,
    this.pickProductImageBytes,
    this.discountRepository = const FarmerDiscountRepository(),
  }) {
    final date = ProductEditOptions.datePartsFor(product.harvestDate);
    imageAsset = product.imageAsset;
    imageBytes = product.imageBytes;
    imageUrl = product.imageUrl;
    nameController.text = product.name;
    priceController.text = ProductEditOptions.stripPeso(product.price);
    weightController.text = ProductEditOptions.stripKg(
      product.availableWeight,
    );
    day = date.day;
    month = date.month;
    year = date.year;
    category = ProductEditOptions.categories.contains(product.category)
        ? product.category
        : null;
    isSold = product.isSold;
    saleStatus = product.saleStatus;
    productionStage = product.productionStage;
    discount = FarmerProductDiscountState(
      id: product.activeSaleId,
      isFarmerOwned: product.activeSaleIsFarmerOwned,
      name: product.activeSaleName,
      discount: product.activeSaleDiscount,
      type: product.activeSaleType,
      value: product.activeSaleValue,
      promoCode: product.activeSalePromoCode,
      startsAt: product.activeSaleStartsAt,
      endsAt: product.activeSaleEndsAt,
    );
  }

  final FarmerDashboardProduct product;
  final ProductImagePicker? pickProductImageBytes;
  final FarmerDiscountRepository discountRepository;

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final weightController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? imageAsset;
  Uint8List? imageBytes;
  String? imageUrl;
  String? day;
  String? month;
  String? year;
  String? category;
  late bool isSold;
  late ProductSaleStatus saleStatus;
  late ProductProductionStage productionStage;
  late FarmerProductDiscountState discount;

  void setDay(String? value) {
    day = value;
    notifyListeners();
  }

  void setMonth(String? value) {
    month = value;
    notifyListeners();
  }

  void setYear(String? value) {
    year = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    category = value;
    notifyListeners();
  }

  void toggleSoldStatus() {
    isSold = !isSold;
    notifyListeners();
  }

  void setSaleStatus(ProductSaleStatus? value) {
    if (value == null) return;
    saleStatus = value;
    notifyListeners();
  }

  void changeProductionStage(ProductProductionStage? value) {
    if (value == null) return;
    productionStage = value;
    if (value != ProductProductionStage.harvested &&
        saleStatus == ProductSaleStatus.readyNow) {
      saleStatus = ProductSaleStatus.notAcceptingOrders;
    }
    notifyListeners();
  }

  Future<void> manageDiscount(BuildContext context) async {
    final updated = await FarmerProductDiscountCoordinator.manageDiscount(
      context: context,
      product: product,
      discountRepository: discountRepository,
      currentDiscount: discount,
    );
    if (updated != null) {
      discount = updated;
      notifyListeners();
    }
  }

  Future<void> removeDiscount(BuildContext context) async {
    final removed =
        await FarmerProductDiscountCoordinator.confirmAndRemoveDiscount(
          context: context,
          saleId: discount.id,
          farmId: product.farmId,
          discountRepository: discountRepository,
        );
    if (removed) {
      discount = FarmerProductDiscountState.empty;
      notifyListeners();
    }
  }

  Future<void> pickImage(BuildContext context) async {
    try {
      final bytes = pickProductImageBytes == null
          ? await pickDeviceProductImage(_imagePicker)
          : await pickProductImageBytes!();
      if (bytes == null) return;
      imageAsset = null;
      imageBytes = bytes;
      imageUrl = null;
      notifyListeners();
    } on Exception {
      if (context.mounted) {
        showProductFormMessage(
          context,
          'Unable to select product photo. Please try again.',
        );
      }
    }
  }

  FarmerDashboardProduct? buildSavedProduct(BuildContext context) =>
      FarmerProductEditBuilder.build(
        context: context,
        baseProduct: product,
        name: nameController.text,
        price: priceController.text,
        weight: weightController.text,
        day: day,
        month: month,
        year: year,
        category: category,
        imageAsset: imageAsset,
        imageBytes: imageBytes,
        imageUrl: imageUrl,
        isSold: isSold,
        saleStatus: saleStatus,
        productionStage: productionStage,
        discount: discount,
      );

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
