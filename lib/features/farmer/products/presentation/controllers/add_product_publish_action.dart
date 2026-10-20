part of 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';

extension _AddProductPublishAction on _AddProductScreenState {
  Future<void> _publishProduct() async {
    if (_isPublishing) return;
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = _priceController.text.trim();
    final quantity = _weightController.text.trim();
    final minimumOrder = _minimumOrderController.text.trim();
    final inventoryLot = _inventoryLotDraft;
    final errors = AddProductDraft.validationErrors(
      photoBytes: _photoBytes,
      name: name,
      category: _category ?? '',
      description: description,
      price: price,
      quantity: quantity,
      minimumOrderQuantity: minimumOrder,
      productionStage: _productionStage,
      sellingOption: _saleStatus,
      expectedDate: _expectedDate,
      inventoryLot: inventoryLot,
    );
    if (errors.isNotEmpty) {
      _refresh(() => _errors = errors);
      showProductFormMessage(context, 'Review the highlighted fields.');
      return;
    }
    final product = FarmerDashboardProduct(
      name: name,
      price: '\u20B1$price',
      unit: 'per $_unitType',
      harvestDate: _displayDate,
      category: _category!,
      availableWeight: '$quantity $_unitType',
      imageBytes: _photoBytes!,
      description: description,
      unitType: _unitType,
      minimumOrderQuantity: minimumOrder,
      gradeQuality: _gradeQuality,
      isOrganic: _isOrganic,
      productionStatus: _productionStage.databaseValue,
      saleStatus: _saleStatus,
      inventoryDateType: inventoryLot.dateType,
      harvestedAt: inventoryLot.harvestedAt,
      sellUntil: inventoryLot.sellUntil,
      expiresAt: inventoryLot.expiresAt,
      lotCode: inventoryLot.lotCode,
      storageInstructions: inventoryLot.storageInstructions,
    );
    final publish = widget.onPublish;
    if (publish == null) {
      Navigator.of(context).pop(product);
      return;
    }
    _refresh(() => _isPublishing = true);
    try {
      final saved = await publish(context, product, _publishRequestKey);
      if (mounted && saved != null) {
        _refresh(() => _isPublishing = false);
        Navigator.of(context).pop(saved);
      }
    } catch (_) {
      if (mounted) {
        showProductFormMessage(
          context,
          'The product could not be published. Please retry.',
        );
      }
    } finally {
      if (mounted) _refresh(() => _isPublishing = false);
    }
  }
}
