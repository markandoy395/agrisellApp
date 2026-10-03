import 'package:flutter/foundation.dart';
import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_context.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';

class FarmerDiscountsController extends ChangeNotifier {
  FarmerDiscountsController({
    int? farmId,
    required this.discountRepository,
    required this.commodityRepository,
  }) : _farmId = farmId;

  FarmerDiscountRepository discountRepository;
  FarmerCommodityRepository commodityRepository;
  int? _farmId;
  bool _disposed = false;
  List<FarmerDiscount> _discounts = const [];
  List<FarmerDashboardProduct> _products = const [];
  bool _isLoading = true;
  bool _loadFailed = false;

  int? get farmId => _farmId;
  List<FarmerDiscount> get discounts => _discounts;
  List<FarmerDashboardProduct> get products => _products;
  bool get isLoading => _isLoading;
  bool get loadFailed => _loadFailed;

  Future<void> load() async {
    _isLoading = true;
    _loadFailed = false;
    notifyListeners();
    try {
      var farmId = _farmId;
      if (farmId == null) {
        final context = await FarmerCommodityContext.load();
        farmId = context.farmId;
        _farmId = farmId;
      }
      final results = await Future.wait([
        discountRepository.loadDiscounts(farmId),
        commodityRepository.loadProducts(),
      ]);
      if (_disposed) return;
      _discounts = results[0] as List<FarmerDiscount>;
      _products = results[1] as List<FarmerDashboardProduct>;
      _isLoading = false;
    } catch (_) {
      if (_disposed) return;
      _loadFailed = true;
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> deleteDiscount(FarmerDiscount discount) =>
      discountRepository.deleteDiscount(discount.saleId, discount.farmId);

  Future<void> setEnabled(FarmerDiscount discount, bool enabled) =>
      discountRepository.updateDiscount(
        saleId: discount.saleId,
        farmId: discount.farmId,
        name: discount.name,
        discountType: discount.discountType,
        discountValue: discount.discountValue,
        startsAt: discount.startsAt,
        endsAt: discount.endsAt,
        promoCode: discount.promoCode,
        isEnabled: enabled,
        commodityIds: discount.commodityIds,
      );

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
