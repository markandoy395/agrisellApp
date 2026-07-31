import 'dart:typed_data';

import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';

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
  }) : _saleStatus = saleStatus ?? ProductSaleStatus.readyNow,
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

  ProductSaleStatus get saleStatus => _saleStatus ?? ProductSaleStatus.readyNow;
  ProductProductionStage get productionStage =>
      productProductionStageFromDatabase(productionStatus);

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
    );
  }
}
