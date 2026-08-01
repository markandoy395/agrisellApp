import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/products/domain/product_edit_options.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/product_edit/product_edit_form_fields.dart';
import 'package:agresell_app/features/shared/products/domain/product_availability_date_rules.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

class ProductEditNameRow extends StatelessWidget {
  const ProductEditNameRow({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => ProductEditInputRow(
    label: 'Product name :',
    child: ProductEditRoundedTextField(
      controller: controller,
      textInputAction: TextInputAction.next,
    ),
  );
}

class ProductEditPriceRow extends StatelessWidget {
  const ProductEditPriceRow({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => ProductEditInputRow(
    label: 'Price :',
    expandChild: false,
    child: SizedBox(
      width: 132,
      child: ProductEditRoundedTextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        prefixText: '\u20B1 ',
      ),
    ),
  );
}

class ProductEditWeightRow extends StatelessWidget {
  const ProductEditWeightRow({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => ProductEditInputRow(
    label: 'Available weight:',
    expandChild: false,
    child: SizedBox(
      width: 132,
      child: ProductEditRoundedTextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        suffixText: 'Kg',
      ),
    ),
  );
}

class ProductEditHarvestDateRow extends StatelessWidget {
  const ProductEditHarvestDateRow({
    required this.day,
    required this.month,
    required this.year,
    required this.productionStage,
    required this.sellingOption,
    required this.onDayChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    super.key,
  });

  final String? day;
  final String? month;
  final String? year;
  final ProductProductionStage productionStage;
  final ProductSaleStatus sellingOption;
  final ValueChanged<String?> onDayChanged;
  final ValueChanged<String?> onMonthChanged;
  final ValueChanged<String?> onYearChanged;

  @override
  Widget build(BuildContext context) {
    final window = ProductAvailabilityDateRules.windowFor(
      productionStage: productionStage,
      sellingOption: sellingOption,
    );
    if (!window.isRequired) return const SizedBox.shrink();
    final selectedDate = ProductEditOptions.dateFor(day, month, year);
    return ProductEditInputRow(
      label: 'Expected availability:',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: () => _pickDate(context, window, selectedDate),
              icon: const Icon(Icons.calendar_month_outlined, size: 17),
              label: Text(
                selectedDate == null
                    ? 'Select date'
                    : '${ProductEditOptions.months[selectedDate.month - 1]} '
                          '${selectedDate.day}, ${selectedDate.year}',
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                foregroundColor: AgrisellColors.authGreen,
                side: const BorderSide(color: AgrisellColors.borderLine),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            window.guidance,
            style: const TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    AvailabilityDateWindow window,
    DateTime? selectedDate,
  ) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate != null && window.includes(selectedDate)
          ? selectedDate
          : window.firstDate,
      firstDate: window.firstDate,
      lastDate: window.lastDate,
      currentDate: ProductAvailabilityDateRules.philippineToday(),
      helpText: 'Expected availability date',
    );
    if (selected == null) return;
    onDayChanged('${selected.day}');
    onMonthChanged(ProductEditOptions.months[selected.month - 1]);
    onYearChanged('${selected.year}');
  }
}

class ProductEditCategoryRow extends StatelessWidget {
  const ProductEditCategoryRow({
    required this.category,
    required this.categories,
    required this.onChanged,
    super.key,
  });

  final String? category;
  final List<String> categories;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => ProductEditInputRow(
    label: 'Categories :',
    expandChild: false,
    child: SizedBox(
      width: 178,
      child: ProductEditCompactDropdown(
        value: category,
        hint: 'Category',
        items: categories,
        onChanged: onChanged,
      ),
    ),
  );
}
