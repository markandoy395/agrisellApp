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
          style: AppDropdownStyle.textStyle.copyWith(fontSize: 12),
          iconEnabledColor: AppDropdownStyle.iconColor,
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AgrisellColors.surface,
            contentPadding: const EdgeInsets.fromLTRB(11, 4, 5, 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: AgrisellColors.authGreen),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: AgrisellColors.authGreen),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: AgrisellColors.authGreen,
                width: 1.4,
              ),
            ),
          ),
          selectedItemBuilder: (context) => [
            for (final status in _options)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  status.farmerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, height: 1),
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
                  style: const TextStyle(fontSize: 12),
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
          style: AppDropdownStyle.textStyle.copyWith(fontSize: 12),
          iconEnabledColor: AppDropdownStyle.iconColor,
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AgrisellColors.surface,
            contentPadding: const EdgeInsets.fromLTRB(11, 4, 5, 4),
            border: _stageBorder(),
            enabledBorder: _stageBorder(),
            focusedBorder: _stageBorder(width: 1.4),
          ),
          selectedItemBuilder: (context) => [
            for (final stage in ProductProductionStage.values)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  stage.farmerLabel,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
          items: [
            for (final stage in ProductProductionStage.values)
              DropdownMenuItem(
                value: stage,
                child: Text(
                  stage.farmerLabel,
                  style: const TextStyle(fontSize: 12),
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
