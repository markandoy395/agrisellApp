import 'package:agresell_app/features/farmer/products/presentation/styles/product_edit_form_fields_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';

class ProductEditInputRow extends StatelessWidget {
  const ProductEditInputRow({
    required this.label,
    required this.child,
    this.expandChild = true,
    super.key,
  });

  final String label;
  final Widget child;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 108,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: ProductEditFormFieldsStyles.labelText,
          ),
        ),
        const SizedBox(width: 13),
        if (expandChild) Expanded(child: child) else child,
      ],
    );
  }
}

class ProductEditRoundedTextField extends StatelessWidget {
  const ProductEditRoundedTextField({
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.prefixText,
    this.suffixText,
    this.readOnly = false,
    super.key,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? prefixText;
  final String? suffixText;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 31,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: ProductEditFormFieldsStyles.textStyle,
        decoration: ProductEditFormFieldsStyles.inputDecoration(
          prefixText,
          suffixText,
        ),
      ),
    );
  }
}

class ProductEditCompactDropdown extends StatelessWidget {
  const ProductEditCompactDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 31,
      child: DropdownButtonFormField<String>(
        dropdownColor: AppDropdownStyle.menuColor,
        borderRadius: AppDropdownStyle.menuBorderRadius,
        style: ProductEditFormFieldsStyles.dropdownButtonFormFieldStyle,
        iconEnabledColor: AppDropdownStyle.iconColor,
        initialValue: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
        decoration: ProductEditFormFieldsStyles.inputDecoration2,
        hint: Text(
          hint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ProductEditFormFieldsStyles.textStyle,
        ),
        selectedItemBuilder: (context) {
          return [
            for (final item in items)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ProductEditFormFieldsStyles.textStyle,
                ),
              ),
          ];
        },
        items: [
          for (final item in items)
            DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SharedPresentationStyles.caption,
              ),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
