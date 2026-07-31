part of 'farmer_shop_screen.dart';

extension _FarmerShopScreenLoading on _FarmerShopScreenState {
  Future<void> _loadProducts() async {
    _updateUi(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final products = await widget.productRepository.loadProductsForFarm(
        farmId: widget.farmer.farmId,
        sellerName: widget.farmer.name,
        sellerLocation: widget.farmer.location,
      );
      if (!mounted) return;
      _updateUi(() {
        _products = products;
        _isLoading = false;
        _loadFailed = false;
      });
    } on Object {
      if (mounted) {
        _updateUi(() {
          _isLoading = false;
          _loadFailed = true;
        });
      }
    }
  }
}
