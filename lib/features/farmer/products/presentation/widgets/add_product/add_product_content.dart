part of 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';

extension _AddProductContent on _AddProductScreenState {
  Widget _buildContent(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(18, 12, 18, 24 + bottomInset),
          child: Column(
            children: [
              Row(
                children: [
                  _BackButton(onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 12),
                  const Text(
                    'Create product listing',
                    style: SharedPresentationStyles.headingTitleExtraBold,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _PhotoPicker(
                photoBytes: _photoBytes,
                errorText: _errors[AddProductField.photo],
                onTap: _pickPhoto,
              ),
              const SizedBox(height: 14),
              _FormPanel(
                nameController: _nameController,
                category: _category,
                categories: _categories,
                errors: _errors,
                onNameChanged: (_) => _clearError(AddProductField.name),
                onCategoryChanged: _changeCategory,
                details: _AdditionalCommodityFields(
                  descriptionController: _descriptionController,
                  errors: _errors,
                  onDescriptionChanged: (_) =>
                      _clearError(AddProductField.description),
                  onGenerateDescription: _generateSampleDescription,
                  pricingFields: _PricingInventoryFields(
                    priceController: _priceController,
                    quantityController: _weightController,
                    minimumOrderController: _minimumOrderController,
                    unitType: _unitType,
                    errors: _errors,
                    onPriceChanged: (_) => _clearError(AddProductField.price),
                    onQuantityChanged: (_) =>
                        _clearError(AddProductField.quantity),
                    onMinimumOrderChanged: (_) =>
                        _clearError(AddProductField.minimumOrder),
                    onUnitTypeChanged: _changeUnitType,
                  ),
                  availabilityFields: _AvailabilityFields(
                    productionStage: _productionStage,
                    sellingOption: _saleStatus,
                    showExpectedDate: _requiresExpectedDate,
                    expectedDate: _expectedDate,
                    dateWindow: _dateWindow,
                    errors: _errors,
                    onProductionStageChanged: _changeProductionStage,
                    onSellingOptionChanged: _changeSellingOption,
                    onSelectExpectedDate: _pickExpectedDate,
                  ),
                  inventoryLotFields: _InventoryLotFields(
                    dateType: _inventoryDateType,
                    allowedDateTypes: _allowedInventoryDateTypes,
                    harvestedAt: _lotHarvestedAt,
                    marketableUntil: _marketableUntil,
                    lotCodeController: _lotCodeController,
                    storageInstructionsController:
                        _storageInstructionsController,
                    errors: _errors,
                    onDateTypeChanged: _changeInventoryDateType,
                    onSelectHarvestDate: _pickLotHarvestDate,
                    onSelectMarketableUntil: _pickMarketableUntil,
                    onLotCodeChanged: (_) =>
                        _clearError(AddProductField.lotCode),
                    onStorageChanged: (_) =>
                        _clearError(AddProductField.storageInstructions),
                  ),
                  gradeQuality: _gradeQuality,
                  isOrganic: _isOrganic,
                  onGradeQualityChanged: (value) {
                    _refresh(() => _gradeQuality = value);
                  },
                  onOrganicChanged: (value) {
                    _refresh(() => _isOrganic = value);
                  },
                ),
                onCancel: () => Navigator.of(context).pop(),
                onPublish: _publishProduct,
                isPublishing: _isPublishing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
