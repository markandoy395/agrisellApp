import 'package:agresell_app/features/shared/products/domain/product_categories.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';

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
    this.salePrice,
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
    ProductInventoryDateType? inventoryDateType,
    this.sellUntil,
    this.expiresAt,
    this.storageInstructions,
  }) : _description = description ?? '',
       _saleStatus = saleStatus ?? ProductSaleStatus.readyNow,
       _productionStage = productionStage ?? ProductProductionStage.harvested,
       _isSold = isSold ?? false,
       _inventoryDateType = inventoryDateType;

  final String id;
  final String name;
  final String price;

  /// A server-resolved sale price for the signed-in buyer, if applicable.
  /// [price] remains the commodity's original price.
  final String? salePrice;
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
  final ProductInventoryDateType? _inventoryDateType;
  final DateTime? sellUntil;
  final DateTime? expiresAt;
  final String? storageInstructions;

  ProductSaleStatus get saleStatus => _saleStatus ?? ProductSaleStatus.readyNow;
  String get description => _description ?? '';
  ProductProductionStage get productionStage =>
      _productionStage ?? ProductProductionStage.harvested;
  bool get isSold => _isSold ?? false;
  ProductInventoryDateType get inventoryDateType =>
      _inventoryDateType ?? ProductInventoryDateType.freshProduce;
  bool get canOrder =>
      isAvailable && saleStatus != ProductSaleStatus.notAcceptingOrders;

  String get buyerStatusLabel {
    if (isSold) return 'Sold out';
    if (!isAvailable) return 'Unavailable';
    return saleStatus.buyerLabel;
  }

  bool get isPreOrder => saleStatus == ProductSaleStatus.preOrder;
  bool get hasSale => salePrice != null && salePrice != price;
  String get activePrice => salePrice ?? price;
  DateTime? get marketableUntil => switch (inventoryDateType) {
    ProductInventoryDateType.freshProduce => sellUntil,
    ProductInventoryDateType.packagedFood => expiresAt,
    ProductInventoryDateType.nonPerishable => null,
  };

  String? get freshnessLabel {
    final date = marketableUntil;
    if (date == null) return null;
    final prefix = inventoryDateType == ProductInventoryDateType.packagedFood
        ? 'Expires'
        : 'Sell until';
    return '$prefix ${_displayInventoryDate(date)}';
  }

  bool get isNearFreshnessDeadline {
    final deadline = marketableUntil;
    if (deadline == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return deadline.difference(today).inDays <= 2;
  }

  String get availableQuantityLabel {
    final quantity = availableQuantityValue;
    return quantity == 'Quantity unavailable'
        ? quantity
        : 'Available: $quantity';
  }

  String get availableQuantityValue {
    final value = availableWeight.trim();
    if (value.isEmpty) return 'Quantity unavailable';
    const suffix = ' available';
    return value.toLowerCase().endsWith(suffix)
        ? value.substring(0, value.length - suffix.length).trimRight()
        : value;
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

const _inventoryMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _displayInventoryDate(DateTime date) =>
    '${_inventoryMonths[date.month - 1]} ${date.day}, ${date.year}';
