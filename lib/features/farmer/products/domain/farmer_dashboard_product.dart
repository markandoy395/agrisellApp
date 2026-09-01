import 'dart:typed_data';

import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';

class FarmerDashboardProduct {
  const FarmerDashboardProduct({
    required this.name,
    required this.price,
    required this.unit,
    required this.harvestDate,
    required this.category,
    this.imageAsset,
    this.imageBytes,
    this.imageUrl,
    this.availableWeight = '',
    this.description = '',
    this.unitType = 'kg',
    this.minimumOrderQuantity = '',
    this.gradeQuality,
    this.isOrganic = false,
    this.productionStatus = 'harvested',
    ProductSaleStatus? saleStatus,
    this.isSold = false,
    this.commodityId,
    this.farmId,
    ProductInventoryDateType? inventoryDateType,
    this.harvestedAt,
    this.sellUntil,
    this.expiresAt,
    this.lotCode,
    this.storageInstructions,
  }) : _saleStatus = saleStatus ?? ProductSaleStatus.readyNow,
       _inventoryDateType = inventoryDateType,
       assert(imageAsset != null || imageBytes != null || imageUrl != null);

  final String name;
  final String price;
  final String unit;
  final String harvestDate;
  final String category;
  final String? imageAsset;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final String availableWeight;
  final String description;
  final String unitType;
  final String minimumOrderQuantity;
  final String? gradeQuality;
  final bool isOrganic;
  final String productionStatus;
  final ProductSaleStatus? _saleStatus;
  final bool isSold;
  final int? commodityId;
  final int? farmId;
  final ProductInventoryDateType? _inventoryDateType;
  final DateTime? harvestedAt;
  final DateTime? sellUntil;
  final DateTime? expiresAt;
  final String? lotCode;
  final String? storageInstructions;

  ProductSaleStatus get saleStatus => _saleStatus ?? ProductSaleStatus.readyNow;
  ProductInventoryDateType get inventoryDateType =>
      _inventoryDateType ?? ProductInventoryDateType.nonPerishable;
  ProductProductionStage get productionStage =>
      productProductionStageFromDatabase(productionStatus);
  double get availableQuantity =>
      double.tryParse(
        RegExp(r'[\d.]+').firstMatch(availableWeight)?.group(0) ?? '',
      ) ??
      0;
  bool get isOutOfStock => !isSold && availableQuantity <= 0;
  ProductInventoryLotDraft get inventoryLot => ProductInventoryLotDraft(
    dateType: inventoryDateType,
    harvestedAt: harvestedAt,
    sellUntil: sellUntil,
    expiresAt: expiresAt,
    lotCode: lotCode,
    storageInstructions: storageInstructions,
  );

  FarmerDashboardProduct copyWith({
    String? name,
    String? price,
    String? unit,
    String? harvestDate,
    String? category,
    String? imageAsset,
    Uint8List? imageBytes,
    String? imageUrl,
    String? availableWeight,
    String? description,
    String? unitType,
    String? minimumOrderQuantity,
    String? gradeQuality,
    bool? isOrganic,
    String? productionStatus,
    ProductSaleStatus? saleStatus,
    bool? isSold,
    int? commodityId,
    int? farmId,
    ProductInventoryDateType? inventoryDateType,
    DateTime? harvestedAt,
    DateTime? sellUntil,
    DateTime? expiresAt,
    String? lotCode,
    String? storageInstructions,
    bool clearImageAsset = false,
    bool clearImageBytes = false,
    bool clearImageUrl = false,
  }) {
    return FarmerDashboardProduct(
      name: name ?? this.name,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      harvestDate: harvestDate ?? this.harvestDate,
      category: category ?? this.category,
      imageAsset: clearImageAsset ? null : imageAsset ?? this.imageAsset,
      imageBytes: clearImageBytes ? null : imageBytes ?? this.imageBytes,
      imageUrl: clearImageUrl ? null : imageUrl ?? this.imageUrl,
      availableWeight: availableWeight ?? this.availableWeight,
      description: description ?? this.description,
      unitType: unitType ?? this.unitType,
      minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
      gradeQuality: gradeQuality ?? this.gradeQuality,
      isOrganic: isOrganic ?? this.isOrganic,
      productionStatus: productionStatus ?? this.productionStatus,
      saleStatus: saleStatus ?? this.saleStatus,
      isSold: isSold ?? this.isSold,
      commodityId: commodityId ?? this.commodityId,
      farmId: farmId ?? this.farmId,
      inventoryDateType: inventoryDateType ?? this.inventoryDateType,
      harvestedAt: harvestedAt ?? this.harvestedAt,
      sellUntil: sellUntil ?? this.sellUntil,
      expiresAt: expiresAt ?? this.expiresAt,
      lotCode: lotCode ?? this.lotCode,
      storageInstructions: storageInstructions ?? this.storageInstructions,
    );
  }
}
