import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

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
            style: const TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: 12,
              height: 1,
              fontWeight: FontWeight.w500,
            ),
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
        style: const TextStyle(fontSize: 12, height: 1),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AgrisellColors.fieldFill,
          prefixText: prefixText,
          suffixText: suffixText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AgrisellColors.authGreen),
          ),
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
        hint: Text(
          hint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, height: 1),
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
                  style: const TextStyle(fontSize: 12, height: 1),
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
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
