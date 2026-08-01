import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_form_actions.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_rows.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_sale_status_row.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_status_button.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';

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

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(25, 31, 25, 30 + bottomInset),
        child: Column(
          children: [
            ProductEditNameRow(controller: nameController),
            const SizedBox(height: 20),
            ProductEditPriceRow(controller: priceController),
            const SizedBox(height: 20),
            ProductEditWeightRow(controller: weightController),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            ProductEditCategoryRow(
              category: category,
              categories: categories,
              onChanged: onCategoryChanged,
            ),
            const SizedBox(height: 20),
            ProductEditProductionStageRow(
              value: productionStage,
              onChanged: onProductionStageChanged,
            ),
            const SizedBox(height: 20),
            ProductEditSaleStatusRow(
              value: saleStatus,
              productionStage: productionStage,
              onChanged: onSaleStatusChanged,
            ),
            const SizedBox(height: 36),
            ProductEditStatusButton(isSold: isSold, onTap: onStatusTap),
            const SizedBox(height: 36),
            ProductEditFormActions(onCancel: onCancel, onSave: onSave),
          ],
        ),
      ),
    );
  }
}
