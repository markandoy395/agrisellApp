import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/add_product_draft.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_image_picker.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_form_message.dart';
import 'package:agresell_app/features/shared/products/domain/product_categories.dart';
import 'package:agresell_app/features/shared/products/domain/product_availability_date_rules.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_options.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_media_widgets.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_form_panel.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_form_fields.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_details_fields.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_pricing_fields.dart';
part 'package:agresell_app/features/farmer/products/presentation/widgets/add_product/add_product_availability_fields.dart';
part 'package:agresell_app/features/farmer/products/presentation/controllers/add_product_screen_actions.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({
    this.pickProductImageBytes,
    this.initialPhotoBytes,
    super.key,
  });
  final ProductImagePicker? pickProductImageBytes;
  final Uint8List? initialPhotoBytes;
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minimumOrderController = TextEditingController();
  final _imagePicker = ImagePicker();
  Uint8List? _photoBytes;
  DateTime? _expectedDate;
  String? _category;
  String _unitType = _unitTypes.first;
  ProductProductionStage _productionStage = ProductProductionStage.harvested;
  ProductSaleStatus _saleStatus = ProductSaleStatus.readyNow;
  String? _gradeQuality;
  var _isOrganic = false;
  Map<AddProductField, String> _errors = {};
  @override
  void initState() {
    super.initState();
    _photoBytes = widget.initialPhotoBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _minimumOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
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
                  gradeQuality: _gradeQuality,
                  isOrganic: _isOrganic,
                  onGradeQualityChanged: (value) {
                    setState(() => _gradeQuality = value);
                  },
                  onOrganicChanged: (value) {
                    setState(() => _isOrganic = value);
                  },
                ),
                onCancel: () => Navigator.of(context).pop(),
                onPublish: _publishProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refresh(VoidCallback change) => setState(change);
}
