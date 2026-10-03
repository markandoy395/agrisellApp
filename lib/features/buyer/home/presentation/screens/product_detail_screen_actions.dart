part of 'product_detail_screen.dart';

extension _ProductDetailScreenActions on _ProductDetailScreenState {
  void _addToBasket() {
    if (!widget.product.canOrder) {
      _showUnavailableMessage();
      return;
    }
    _basketController.addProduct(widget.product, quantity: _quantity.value);
    _showAddedFeedback.value = true;

    _addedFeedbackTimer?.cancel();
    _addedFeedbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        _showAddedFeedback.value = false;
      }
    });
  }

  void _buyNow() {
    if (!widget.product.canOrder) {
      _showUnavailableMessage();
      return;
    }

    _basketController.addProduct(widget.product, quantity: _quantity.value);
    Navigator.of(context).pushNamed(AgrisellRoutes.checkout);
  }

  void _showUnavailableMessage() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showAppSnackBar(
      SnackBar(
        content: Text('${widget.product.name} is not accepting orders now.'),
      ),
    );
  }

  void _incrementQuantity() {
    if (_quantity.value < 99) _quantity.value++;
  }

  void _decrementQuantity() {
    if (_quantity.value > 1) _quantity.value--;
  }

  void _openProduct(HomeProduct product) {
    Navigator.of(context).push(
      agrisellMaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(
          product: product,
          catalogController: _catalogController,
          isSaved: widget.isSaved,
          onSavedToggle: widget.onSavedToggle,
        ),
      ),
    );
  }
}
