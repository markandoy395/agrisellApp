import 'package:agresell_app/features/shared/products/domain/product_categories.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

class HomeProduct {
  const HomeProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.image,
    required this.harvestDate,
    required this.availableWeight,
    required this.sellerName,
    required this.sellerLocation,
    String? description,
    this.category = ProductCategories.vegetables,
    this.isAvailable = true,
    this.sellerImage = '',
    this.imageUrl,
    this.farmId,
    this.rating = 0,
    ProductSaleStatus? saleStatus,
    ProductProductionStage? productionStage,
    this.estimatedHarvestDate,
    bool? isSold,
  }) : _description = description ?? '',
       _saleStatus = saleStatus ?? ProductSaleStatus.readyNow,
       _productionStage = productionStage ?? ProductProductionStage.harvested,
       _isSold = isSold ?? false;

  final String id;
  final String name;
  final String price;
  final String unit;
  final String image;
  final String harvestDate;
  final String availableWeight;
  final String sellerName;
  final String sellerLocation;
  final String? _description;
  final String category;
  final bool isAvailable;
  final String sellerImage;
  final String? imageUrl;
  final int? farmId;
  final double rating;
  final ProductSaleStatus? _saleStatus;
  final ProductProductionStage? _productionStage;
  final DateTime? estimatedHarvestDate;
  final bool? _isSold;

  ProductSaleStatus get saleStatus => _saleStatus ?? ProductSaleStatus.readyNow;
  String get description => _description ?? '';
  ProductProductionStage get productionStage =>
      _productionStage ?? ProductProductionStage.harvested;
  bool get isSold => _isSold ?? false;
  bool get canOrder =>
      isAvailable && saleStatus != ProductSaleStatus.notAcceptingOrders;

  String get buyerStatusLabel {
    if (isSold) return 'Sold out';
    if (!isAvailable) return 'Unavailable';
    return saleStatus.buyerLabel;
  }

  bool get isPreOrder => saleStatus == ProductSaleStatus.preOrder;

  String get availableQuantityLabel {
    final value = availableWeight.trim();
    if (value.isEmpty) return 'Available quantity unavailable';
    const suffix = ' available';
    final quantity = value.toLowerCase().endsWith(suffix)
        ? value.substring(0, value.length - suffix.length).trimRight()
        : value;
    return 'Available: $quantity';
  }

  String? get harvestCountdown {
    if (productionStage == ProductProductionStage.harvested &&
        saleStatus == ProductSaleStatus.readyNow) {
      return null;
    }
    final target = estimatedHarvestDate;
    if (target == null) return 'Harvest date pending';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final harvestDay = DateTime(target.year, target.month, target.day);
    final days = harvestDay.difference(today).inDays;
    if (days < 0) return 'Harvest date needs confirmation';
    if (days == 0) return 'Harvests today';
    if (days == 1) return 'Harvests tomorrow';
    return 'Harvest in $days days';
  }
}
