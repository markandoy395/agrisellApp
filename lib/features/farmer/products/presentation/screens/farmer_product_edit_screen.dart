import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/discounts/data/farmer_discount_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/product_edit_options.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/farmer_product_edit_controller.dart';
import 'package:agresell_app/features/farmer/products/presentation/controllers/product_image_picker.dart';
import 'package:agresell_app/features/farmer/products/presentation/styles/farmer_product_edit_styles.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/farmer_product_edit_form_panel.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_image_header.dart';

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
  late final FarmerProductEditController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FarmerProductEditController(
      product: widget.product,
      pickProductImageBytes: widget.pickProductImageBytes,
      discountRepository: widget.discountRepository,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveProduct() {
    final edited = _controller.buildSavedProduct(context);
    if (edited != null) Navigator.of(context).pop(edited);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final imageHeight = FarmerProductEditStyles.calculateImageHeight(
      width,
      keyboardVisible: bottomInset > 0,
      availableHeight: MediaQuery.sizeOf(context).height - bottomInset,
    );

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: FarmerProductEditStyles.backgroundColor,
        body: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: imageHeight,
              child: ProductEditImageHeader(
                imageAsset: _controller.imageAsset,
                imageBytes: _controller.imageBytes,
                imageUrl: _controller.imageUrl,
                onBack: () => Navigator.of(context).pop(),
                onCameraTap: () => _controller.pickImage(context),
              ),
            ),
            Positioned(
              left: 0,
              top: imageHeight - FarmerProductEditStyles.panelOverlap,
              right: 0,
              bottom: 0,
              child: FarmerProductEditFormPanel(
                nameController: _controller.nameController,
                priceController: _controller.priceController,
                weightController: _controller.weightController,
                day: _controller.day,
                month: _controller.month,
                year: _controller.year,
                category: _controller.category,
                categories: ProductEditOptions.categories,
                isSold: _controller.isSold,
                saleStatus: _controller.saleStatus,
                productionStage: _controller.productionStage,
                onDayChanged: _controller.setDay,
                onMonthChanged: _controller.setMonth,
                onYearChanged: _controller.setYear,
                onCategoryChanged: _controller.setCategory,
                onStatusTap: _controller.toggleSoldStatus,
                onSaleStatusChanged: _controller.setSaleStatus,
                onProductionStageChanged: _controller.changeProductionStage,
                onCancel: () => Navigator.of(context).pop(),
                onSave: _saveProduct,
                activeSaleNotice: _controller.discount.notice,
                isFarmerDiscount: _controller.discount.isFarmerOwned,
                onManageDiscount: () => _controller.manageDiscount(context),
                onRemoveDiscount: _controller.discount.isFarmerOwned
                    ? () => _controller.removeDiscount(context)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
