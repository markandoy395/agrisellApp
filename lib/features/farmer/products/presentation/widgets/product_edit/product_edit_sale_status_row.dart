import 'package:agresell_app/features/farmer/products/presentation/styles/product_edit_sale_status_row_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_form_fields.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';

class ProductEditSaleStatusRow extends StatelessWidget {
  const ProductEditSaleStatusRow({
    required this.value,
    required this.productionStage,
    required this.onChanged,
    super.key,
  });

  final ProductSaleStatus value;
  final ProductProductionStage productionStage;
  final ValueChanged<ProductSaleStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ProductEditInputRow(
      label: 'Selling status :',
      child: SizedBox(
        height: 31,
        child: DropdownButtonFormField<ProductSaleStatus>(
          dropdownColor: AppDropdownStyle.menuColor,
          borderRadius: AppDropdownStyle.menuBorderRadius,
          style: ProductEditSaleStatusRowStyles.dropdownButtonFormFieldStyle,
          iconEnabledColor: AppDropdownStyle.iconColor,
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
          decoration: ProductEditSaleStatusRowStyles.inputDecoration,
          selectedItemBuilder: (context) => [
            for (final status in _options)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  status.farmerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ProductEditSaleStatusRowStyles.textStyle,
                ),
              ),
          ],
          items: [
            for (final status in _options)
              DropdownMenuItem<ProductSaleStatus>(
                value: status,
                child: Text(
                  status.farmerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SharedPresentationStyles.caption,
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  List<ProductSaleStatus> get _options {
    if (productionStage == ProductProductionStage.harvested) {
      return ProductSaleStatus.values;
    }
    return const [
      ProductSaleStatus.preOrder,
      ProductSaleStatus.notAcceptingOrders,
    ];
  }
}

class ProductEditProductionStageRow extends StatelessWidget {
  const ProductEditProductionStageRow({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ProductProductionStage value;
  final ValueChanged<ProductProductionStage?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ProductEditInputRow(
      label: 'Production stage :',
      child: SizedBox(
        height: 31,
        child: DropdownButtonFormField<ProductProductionStage>(
          dropdownColor: AppDropdownStyle.menuColor,
          borderRadius: AppDropdownStyle.menuBorderRadius,
          style: ProductEditSaleStatusRowStyles.dropdownButtonFormFieldStyle,
          iconEnabledColor: AppDropdownStyle.iconColor,
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
          decoration: ProductEditSaleStatusRowStyles.inputDecoration2(
            _stageBorder(),
            _stageBorder(width: 1.4),
          ),
          selectedItemBuilder: (context) => [
            for (final stage in ProductProductionStage.values)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  stage.farmerLabel,
                  overflow: TextOverflow.ellipsis,
                  style: SharedPresentationStyles.caption,
                ),
              ),
          ],
          items: [
            for (final stage in ProductProductionStage.values)
              DropdownMenuItem(
                value: stage,
                child: Text(
                  stage.farmerLabel,
                  style: SharedPresentationStyles.caption,
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  OutlineInputBorder _stageBorder({double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: AgrisellColors.authGreen, width: width),
    );
  }
}
