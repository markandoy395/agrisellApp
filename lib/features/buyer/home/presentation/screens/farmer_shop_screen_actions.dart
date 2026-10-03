part of 'farmer_shop_screen.dart';

extension _FarmerShopScreenActions on _FarmerShopScreenState {
  Future<void> _loadFollowState() async {
    try {
      await _followController.refresh(widget.farmer);
    } on Object {
      // Keep the directory-provided state when a refresh is unavailable.
    }
  }

  void _openChat() {
    unawaited(
      BuyerConversationLauncher.open(
        context,
        sellerName: widget.farmer.name,
        farmId: widget.farmer.farmId,
      ),
    );
  }

  void _openProduct(HomeProduct product) {
    if (!product.isAvailable) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('This product is unavailable.')),
      );
      return;
    }

    Navigator.of(context).push(
      agrisellMaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(
          product: product,
          productRepository: widget.productRepository,
        ),
      ),
    );
  }

  void _handleMenuAction(FarmerShopMenuAction action) {
    switch (action) {
      case FarmerShopMenuAction.viewAllProducts:
        _updateUi(() {
          _activeTab = FarmerShopTab.products;
          _selectedCategory = null;
          _searchQuery = '';
          _searchController.clear();
        });
      case FarmerShopMenuAction.messageFarmer:
        _openChat();
    }
  }
}
