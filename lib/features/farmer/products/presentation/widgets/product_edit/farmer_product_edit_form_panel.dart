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
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(25, 31, 25, 30 + bottomInset),
        child: Column(
          children: [
            if (activeSaleNotice != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AgrisellColors.forestSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AgrisellColors.authGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_offer_rounded,
                          color: AgrisellColors.authGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFarmerDiscount
                                    ? 'Active Product Promotion'
                                    : 'Featured in Active Admin Sale',
                                style: const TextStyle(
                                  color: AgrisellColors.authGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activeSaleNotice!,
                                style: const TextStyle(
                                  color: AgrisellColors.brandBlack,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isFarmerDiscount && onManageDiscount != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: onManageDiscount,
                            icon: const Icon(Icons.edit_outlined, size: 14),
                            label: const Text('Edit Discount'),
                            style: TextButton.styleFrom(
                              foregroundColor: AgrisellColors.authGreen,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                          if (onRemoveDiscount != null) ...[
                            const SizedBox(width: 4),
                            TextButton.icon(
                              onPressed: onRemoveDiscount,
                              icon: const Icon(Icons.delete_outline_rounded, size: 14),
                              label: const Text('Remove'),
                              style: TextButton.styleFrom(
                                foregroundColor: AgrisellColors.statusRedText,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else if (onManageDiscount != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AgrisellColors.homeBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AgrisellColors.borderLine,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_offer_outlined,
                      color: AgrisellColors.mutedText,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product Discount',
                            style: TextStyle(
                              color: AgrisellColors.brandBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'No active promotion on this product.',
                            style: TextStyle(
                              color: AgrisellColors.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: onManageDiscount,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AgrisellColors.authGreen,
                        side: const BorderSide(color: AgrisellColors.authGreen),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Put on Sale',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
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
