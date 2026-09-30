import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/product_edit_options.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_image_picker.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_form_message.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/farmer_product_edit_form_panel.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_image_header.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/farmer/discounts/domain/farmer_discount.dart';
import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/discounts/presentation/widgets/farmer_discount_dialog.dart';

class FarmerProductEditScreen extends StatefulWidget {
  const FarmerProductEditScreen({
    required this.product,
    this.pickProductImageBytes,
    this.discountRepository = const FarmerDiscountRepository(),
    super.key,
  });
  final FarmerDashboardProduct product;
  final ProductImagePicker? pickProductImageBytes;
  final FarmerDiscountRepository discountRepository;
  @override
  State<FarmerProductEditScreen> createState() =>
      _FarmerProductEditScreenState();
}

class _FarmerProductEditScreenState extends State<FarmerProductEditScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _imageAsset;
  Uint8List? _imageBytes;
  String? _imageUrl;
  String? _day;
  String? _month;
  String? _year;
  String? _category;
  late bool _isSold;
  late ProductSaleStatus _saleStatus;
  late ProductProductionStage _productionStage;
  String? _activeSaleName;
  String? _activeSaleDiscount;
  int? _activeSaleId;
  bool _activeSaleIsFarmerOwned = false;
  String? _activeSaleType;
  double? _activeSaleValue;
  String? _activeSalePromoCode;
  DateTime? _activeSaleStartsAt;
  DateTime? _activeSaleEndsAt;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    final date = ProductEditOptions.datePartsFor(product.harvestDate);
    _imageAsset = product.imageAsset;
    _imageBytes = product.imageBytes;
    _imageUrl = product.imageUrl;
    _nameController.text = product.name;
    _priceController.text = ProductEditOptions.stripPeso(product.price);
    _weightController.text = ProductEditOptions.stripKg(
      product.availableWeight,
    );
    _day = date.day;
    _month = date.month;
    _year = date.year;
    _category = ProductEditOptions.categories.contains(product.category)
        ? product.category
        : null;
    _isSold = product.isSold;
    _saleStatus = product.saleStatus;
    _productionStage = product.productionStage;
    _activeSaleName = product.activeSaleName;
    _activeSaleDiscount = product.activeSaleDiscount;
    _activeSaleId = product.activeSaleId;
    _activeSaleIsFarmerOwned = product.activeSaleIsFarmerOwned;
    _activeSaleType = product.activeSaleType;
    _activeSaleValue = product.activeSaleValue;
    _activeSalePromoCode = product.activeSalePromoCode;
    _activeSaleStartsAt = product.activeSaleStartsAt;
    _activeSaleEndsAt = product.activeSaleEndsAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final imageHeight = (width * 0.84).clamp(292.0, 360.0);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: imageHeight,
            child: ProductEditImageHeader(
              imageAsset: _imageAsset,
              imageBytes: _imageBytes,
              imageUrl: _imageUrl,
              onBack: () => Navigator.of(context).pop(),
              onCameraTap: _pickImage,
            ),
          ),
          Positioned(
            left: 0,
            top: imageHeight - 28,
            right: 0,
            bottom: 0,
            child: FarmerProductEditFormPanel(
              bottomInset: bottomInset,
              nameController: _nameController,
              priceController: _priceController,
              weightController: _weightController,
              day: _day,
              month: _month,
              year: _year,
              category: _category,
              categories: ProductEditOptions.categories,
              isSold: _isSold,
              saleStatus: _saleStatus,
              productionStage: _productionStage,
              onDayChanged: (value) => setState(() => _day = value),
              onMonthChanged: (value) => setState(() => _month = value),
              onYearChanged: (value) => setState(() => _year = value),
              onCategoryChanged: (value) => setState(() => _category = value),
              onStatusTap: () => setState(() => _isSold = !_isSold),
              onSaleStatusChanged: (value) {
                if (value != null) setState(() => _saleStatus = value);
              },
              onProductionStageChanged: _changeProductionStage,
              onCancel: () => Navigator.of(context).pop(),
              onSave: _saveProduct,
              activeSaleNotice: _activeSaleNotice,
              isFarmerDiscount: _activeSaleIsFarmerOwned,
              onManageDiscount: _manageDiscount,
              onRemoveDiscount: _activeSaleIsFarmerOwned ? _removeDiscount : null,
            ),
          ),
        ],
      ),
    );
  }

  String? get _activeSaleNotice {
    if (_activeSaleName == null || _activeSaleName!.trim().isEmpty) return null;
    return '$_activeSaleName (${_activeSaleDiscount ?? 'Discounted'})';
  }

  Future<void> _manageDiscount() async {
    final farmId = widget.product.farmId;
    if (farmId == null) {
      showProductFormMessage(context, 'Please save product before adding discount.');
      return;
    }

    FarmerDiscount? existing;
    if (_activeSaleId != null && _activeSaleIsFarmerOwned) {
      existing = FarmerDiscount(
        saleId: _activeSaleId!,
        farmId: farmId,
        name: _activeSaleName ?? 'Product Discount',
        discountType: _activeSaleType ?? 'percentage',
        discountValue: _activeSaleValue ?? 0.0,
        startsAt: _activeSaleStartsAt,
        endsAt: _activeSaleEndsAt,
        promoCode: _activeSalePromoCode,
        commodityIds: widget.product.commodityId != null ? [widget.product.commodityId!] : [],
      );
    }

    final saved = await showFarmerDiscountDialog(
      context,
      farmId: farmId,
      existingDiscount: existing,
      initialProduct: widget.product,
      discountRepository: widget.discountRepository,
    );

    if (saved != null && mounted) {
      setState(() {
        _activeSaleId = saved.saleId;
        _activeSaleIsFarmerOwned = true;
        _activeSaleName = saved.name;
        _activeSaleDiscount = saved.discountLabel;
        _activeSaleType = saved.discountType;
        _activeSaleValue = saved.discountValue;
        _activeSalePromoCode = saved.promoCode;
        _activeSaleStartsAt = saved.startsAt;
        _activeSaleEndsAt = saved.endsAt;
      });
      showProductFormMessage(context, 'Discount applied: ${saved.discountLabel}');
    }
  }

  Future<void> _removeDiscount() async {
    final saleId = _activeSaleId;
    final farmId = widget.product.farmId;
    if (saleId == null || farmId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Discount?'),
        content: const Text('Are you sure you want to remove the discount from this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AgrisellColors.statusRedText,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await widget.discountRepository.deleteDiscount(saleId, farmId);
      if (!mounted) return;
      setState(() {
        _activeSaleId = null;
        _activeSaleIsFarmerOwned = false;
        _activeSaleName = null;
        _activeSaleDiscount = null;
        _activeSaleType = null;
        _activeSaleValue = null;
        _activeSalePromoCode = null;
        _activeSaleStartsAt = null;
        _activeSaleEndsAt = null;
      });
      showProductFormMessage(context, 'Discount removed.');
    } catch (_) {
      if (!mounted) return;
      showProductFormMessage(context, 'Failed to remove discount.');
    }
  }

  Future<void> _pickImage() async {
    final picker = widget.pickProductImageBytes;
    try {
      final bytes = picker == null
          ? await pickDeviceProductImage(_imagePicker)
          : await picker();
      if (!mounted || bytes == null) return;
      setState(() {
        _imageAsset = null;
        _imageBytes = bytes;
        _imageUrl = null;
      });
    } on Exception {
      showProductFormMessage(
        context,
        'Unable to select product photo. Please try again.',
      );
    }
  }

  void _changeProductionStage(ProductProductionStage? value) {
    if (value == null) return;
    setState(() {
      _productionStage = value;
      if (value != ProductProductionStage.harvested &&
          _saleStatus == ProductSaleStatus.readyNow) {
        _saleStatus = ProductSaleStatus.notAcceptingOrders;
      }
    });
  }

  void _saveProduct() {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();
    final weight = _weightController.text.trim();
    final day = _day;
    final month = _month;
    final year = _year;
    final category = _category;
    final error = ProductEditOptions.validateForm(
      hasImage: _imageAsset != null || _imageBytes != null || _imageUrl != null,
      name: name,
      price: price,
      weight: weight,
      day: day,
      month: month,
      year: year,
      category: category,
      productionStage: _productionStage,
      sellingOption: _saleStatus,
    );
    if (error != null) {
      showProductFormMessage(context, error);
      return;
    }
    final edited = ProductEditOptions.editedProduct(
      baseProduct: widget.product,
      name: name,
      price: price,
      weight: weight,
      day: day,
      month: month,
      year: year,
      category: category!,
      imageAsset: _imageAsset,
      imageBytes: _imageBytes,
      imageUrl: _imageUrl,
      isSold: _isSold,
      saleStatus: _saleStatus,
      productionStage: _productionStage,
    );
    Navigator.of(context).pop(
      edited.copyWith(
        activeSaleId: _activeSaleId,
        activeSaleIsFarmerOwned: _activeSaleIsFarmerOwned,
        activeSaleName: _activeSaleName,
        activeSaleDiscount: _activeSaleDiscount,
        activeSaleType: _activeSaleType,
        activeSaleValue: _activeSaleValue,
        activeSalePromoCode: _activeSalePromoCode,
        activeSaleStartsAt: _activeSaleStartsAt,
        activeSaleEndsAt: _activeSaleEndsAt,
        clearActiveSale: _activeSaleName == null,
      ),
    );
  }
}
