import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/products/presentation/styles/farmer_product_edit_form_panel_styles.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_discount_banner.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_form_actions.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_rows.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_sale_status_row.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_status_button.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

class FarmerProductEditFormPanel extends StatelessWidget {
  const FarmerProductEditFormPanel({
    required this.bottomInset,
    required this.nameController,
    required this.priceController,
    required this.weightController,
    required this.day,
    required this.month,
    required this.year,
    required this.category,
    required this.categories,
    required this.isSold,
    required this.saleStatus,
    required this.productionStage,
    required this.onDayChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onCategoryChanged,
    required this.onStatusTap,
    required this.onSaleStatusChanged,
    required this.onProductionStageChanged,
    required this.onCancel,
    required this.onSave,
    this.activeSaleNotice,
    this.isFarmerDiscount = false,
    this.onManageDiscount,
    this.onRemoveDiscount,
    super.key,
  });

  final double bottomInset;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController weightController;
  final String? day;
  final String? month;
  final String? year;
  final String? category;
  final List<String> categories;
  final bool isSold;
  final ProductSaleStatus saleStatus;
  final ProductProductionStage productionStage;
  final ValueChanged<String?> onDayChanged;
  final ValueChanged<String?> onMonthChanged;
  final ValueChanged<String?> onYearChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onStatusTap;
  final ValueChanged<ProductSaleStatus?> onSaleStatusChanged;
  final ValueChanged<ProductProductionStage?> onProductionStageChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String? activeSaleNotice;
  final bool isFarmerDiscount;
  final VoidCallback? onManageDiscount;
  final VoidCallback? onRemoveDiscount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: FarmerProductEditFormPanelStyles.panelDecoration,
      child: SingleChildScrollView(
        padding: FarmerProductEditFormPanelStyles.panelPadding(bottomInset),
        child: Column(
          children: [
            ProductEditDiscountBanner(
              activeSaleNotice: activeSaleNotice,
              isFarmerDiscount: isFarmerDiscount,
              onManageDiscount: onManageDiscount,
              onRemoveDiscount: onRemoveDiscount,
            ),
            ProductEditNameRow(controller: nameController),
            FarmerProductEditFormPanelStyles.rowSpacing,
            ProductEditPriceRow(controller: priceController),
            FarmerProductEditFormPanelStyles.rowSpacing,
            ProductEditWeightRow(controller: weightController),
            FarmerProductEditFormPanelStyles.rowSpacing,
            ProductEditHarvestDateRow(
              day: day,
              month: month,
              year: year,
              productionStage: productionStage,
              sellingOption: saleStatus,
              onDayChanged: onDayChanged,
              onMonthChanged: onMonthChanged,
              onYearChanged: onYearChanged,
            ),
            FarmerProductEditFormPanelStyles.rowSpacing,
            ProductEditCategoryRow(
              category: category,
              categories: categories,
              onChanged: onCategoryChanged,
            ),
            FarmerProductEditFormPanelStyles.rowSpacing,
            ProductEditProductionStageRow(
              value: productionStage,
              onChanged: onProductionStageChanged,
            ),
            FarmerProductEditFormPanelStyles.rowSpacing,
            ProductEditSaleStatusRow(
              value: saleStatus,
              productionStage: productionStage,
              onChanged: onSaleStatusChanged,
            ),
            FarmerProductEditFormPanelStyles.actionSpacing,
            ProductEditStatusButton(isSold: isSold, onTap: onStatusTap),
            FarmerProductEditFormPanelStyles.actionSpacing,
            ProductEditFormActions(onCancel: onCancel, onSave: onSave),
          ],
        ),
      ),
    );
  }
}
