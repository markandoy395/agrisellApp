part of 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';

extension _AddProductScreenActions on _AddProductScreenState {
  bool get _requiresExpectedDate => _dateWindow.isRequired;

  AvailabilityDateWindow get _dateWindow =>
      ProductAvailabilityDateRules.windowFor(
        productionStage: _productionStage,
        sellingOption: _saleStatus,
      );

  Future<void> _pickPhoto() async {
    try {
      final picker = widget.pickProductImageBytes;
      final bytes = picker == null
          ? await pickDeviceProductImage(_imagePicker)
          : await picker();
      if (!mounted || bytes == null) return;
      _refresh(() {
        _photoBytes = bytes;
        _errors.remove(AddProductField.photo);
      });
    } catch (_) {
      if (mounted) {
        showProductFormMessage(
          context,
          'Unable to select product photo. Please try again.',
        );
      }
    }
  }

  void _publishProduct() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = _priceController.text.trim();
    final quantity = _weightController.text.trim();
    final minimumOrder = _minimumOrderController.text.trim();
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
    );
    if (errors.isNotEmpty) {
      _refresh(() => _errors = errors);
      showProductFormMessage(context, 'Review the highlighted fields.');
      return;
    }
    Navigator.of(context).pop(
      FarmerDashboardProduct(
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
      ),
    );
  }

  String get _displayDate {
    final date = _expectedDate;
    if (_requiresExpectedDate && date != null) {
      return '${_months[date.month - 1]} ${date.day}, ${date.year}';
    }
    final today = ProductAvailabilityDateRules.philippineToday();
    return '${_months[today.month - 1]} ${today.day}, ${today.year}';
  }

  void _clearError(AddProductField field) {
    if (!_errors.containsKey(field)) return;
    _refresh(() => _errors = Map.of(_errors)..remove(field));
  }

  void _changeCategory(String? value) => _refresh(() {
    _category = value;
    _errors.remove(AddProductField.category);
  });

  void _changeUnitType(String? value) {
    if (value != null) _refresh(() => _unitType = value);
  }

  void _changeProductionStage(ProductProductionStage? value) {
    if (value == null) return;
    _refresh(() {
      _productionStage = value;
      if (value != ProductProductionStage.harvested &&
          _saleStatus == ProductSaleStatus.readyNow) {
        _saleStatus = ProductSaleStatus.notAcceptingOrders;
      }
      if (!_requiresExpectedDate) {
        _errors.remove(AddProductField.harvestDate);
      }
      _normalizeExpectedDate();
    });
  }

  void _changeSellingOption(ProductSaleStatus? value) {
    if (value == null) return;
    _refresh(() {
      _saleStatus = value;
      if (!_requiresExpectedDate) {
        _errors.remove(AddProductField.harvestDate);
      }
      _normalizeExpectedDate();
    });
  }

  Future<void> _pickExpectedDate() async {
    final window = _dateWindow;
    final current = _expectedDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: current != null && window.includes(current)
          ? current
          : window.firstDate,
      firstDate: window.firstDate,
      lastDate: window.lastDate,
      currentDate: ProductAvailabilityDateRules.philippineToday(),
      helpText: 'Expected availability date',
    );
    if (!mounted || selected == null) return;
    _refresh(() {
      _expectedDate = selected;
      _errors.remove(AddProductField.harvestDate);
    });
  }

  void _normalizeExpectedDate() {
    final date = _expectedDate;
    if (date != null && !_dateWindow.includes(date)) _expectedDate = null;
  }
}
