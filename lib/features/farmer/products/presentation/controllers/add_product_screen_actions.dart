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
        inventoryDateType: inventoryLot.dateType,
        harvestedAt: inventoryLot.harvestedAt,
        sellUntil: inventoryLot.sellUntil,
        expiresAt: inventoryLot.expiresAt,
        lotCode: inventoryLot.lotCode,
        storageInstructions: inventoryLot.storageInstructions,
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
    if (value == ProductCategories.fruitTrees) {
      _inventoryDateType = ProductInventoryDateType.nonPerishable;
      _marketableUntil = null;
    } else if (_inventoryDateType == ProductInventoryDateType.nonPerishable) {
      _inventoryDateType = ProductInventoryDateType.freshProduce;
    }
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
      if (value == ProductProductionStage.harvested) {
        _lotHarvestedAt = ProductAvailabilityDateRules.philippineToday();
      }
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
      _lotHarvestedAt = selected;
      _errors.remove(AddProductField.harvestDate);
      _errors.remove(AddProductField.lotHarvestDate);
    });
  }

  void _normalizeExpectedDate() {
    final date = _expectedDate;
    if (date != null && !_dateWindow.includes(date)) _expectedDate = null;
  }

  ProductInventoryLotDraft get _inventoryLotDraft => ProductInventoryLotDraft(
    dateType: _inventoryDateType,
    harvestedAt: _inventoryDateType == ProductInventoryDateType.nonPerishable
        ? null
        : _lotHarvestedAt,
    sellUntil: _inventoryDateType == ProductInventoryDateType.freshProduce
        ? _marketableUntil
        : null,
    expiresAt: _inventoryDateType == ProductInventoryDateType.packagedFood
        ? _marketableUntil
        : null,
    lotCode: _lotCodeController.text.trim().isEmpty
        ? null
        : _lotCodeController.text.trim(),
    storageInstructions: _storageInstructionsController.text.trim().isEmpty
        ? null
        : _storageInstructionsController.text.trim(),
  );

  List<ProductInventoryDateType> get _allowedInventoryDateTypes {
    if (_category == ProductCategories.fruitTrees) {
      return const [ProductInventoryDateType.nonPerishable];
    }
    return const [
      ProductInventoryDateType.freshProduce,
      ProductInventoryDateType.packagedFood,
    ];
  }

  void _changeInventoryDateType(ProductInventoryDateType? value) {
    if (value == null) return;
    _refresh(() {
      _inventoryDateType = value;
      _marketableUntil = null;
      _errors.remove(AddProductField.lotHarvestDate);
      _errors.remove(AddProductField.marketableUntil);
      _errors.remove(AddProductField.lotCode);
    });
  }

  Future<void> _pickLotHarvestDate() async {
    final today = ProductAvailabilityDateRules.philippineToday();
    final latest = _productionStage == ProductProductionStage.harvested
        ? today
        : _dateWindow.lastDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: _lotHarvestedAt ?? today,
      firstDate: DateTime(today.year - 2),
      lastDate: latest,
      currentDate: today,
      helpText: 'Harvest or production date',
    );
    if (!mounted || selected == null) return;
    _refresh(() {
      _lotHarvestedAt = selected;
      if (_marketableUntil != null && _marketableUntil!.isBefore(selected)) {
        _marketableUntil = null;
      }
      _errors.remove(AddProductField.lotHarvestDate);
    });
  }

  Future<void> _pickMarketableUntil() async {
    final today = ProductAvailabilityDateRules.philippineToday();
    final harvest = _lotHarvestedAt;
    final firstDate = harvest != null && harvest.isAfter(today)
        ? harvest
        : today;
    final selected = await showDatePicker(
      context: context,
      initialDate: _marketableUntil ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime(firstDate.year + 10, firstDate.month, firstDate.day),
      currentDate: today,
      helpText: _inventoryDateType == ProductInventoryDateType.packagedFood
          ? 'Printed expiration date'
          : 'Final selling date',
    );
    if (!mounted || selected == null) return;
    _refresh(() {
      _marketableUntil = selected;
      _errors.remove(AddProductField.marketableUntil);
    });
  }
}
