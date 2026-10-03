part of 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';

class _InputRow extends StatelessWidget {
  const _InputRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              label,
              maxLines: 2,
              style: AddProductFormFieldsStyles.labelText,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  const _RoundedTextField({
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.prefixText,
    this.suffixText,
    this.hintText,
    this.errorText,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? prefixText;
  final String? suffixText;
  final String? hintText;
  final String? errorText;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      style: SharedPresentationStyles.body,
      decoration: AddProductFormFieldsStyles.inputDecoration(
        prefixText,
        suffixText,
        hintText,
        errorText,
        _textFieldBorder(AgrisellColors.borderLine),
        _textFieldBorder(AgrisellColors.authGreen, width: 1.4),
        _textFieldBorder(AgrisellColors.statusRedText),
        _textFieldBorder(AgrisellColors.statusRedText, width: 1.4),
      ),
    );
  }

  OutlineInputBorder _textFieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _CompactDropdown<T> extends StatelessWidget {
  const _CompactDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.errorText,
    this.itemLabel,
  });

  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? errorText;
  final String Function(T value)? itemLabel;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      dropdownColor: AppDropdownStyle.menuColor,
      borderRadius: AppDropdownStyle.menuBorderRadius,
      style: AddProductFormFieldsStyles.dropdownButtonFormFieldStyle,
      iconEnabledColor: AppDropdownStyle.iconColor,
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
      decoration: AddProductFormFieldsStyles.inputDecoration2(
        errorText,
        _dropdownBorder(AgrisellColors.borderLine),
        _dropdownBorder(AgrisellColors.authGreen, width: 1.4),
        _dropdownBorder(AgrisellColors.statusRedText),
        _dropdownBorder(AgrisellColors.statusRedText, width: 1.4),
      ),
      hint: Text(
        hint,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: SharedPresentationStyles.caption,
      ),
      selectedItemBuilder: (context) {
        return [
          for (final item in items)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _label(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SharedPresentationStyles.caption,
              ),
            ),
        ];
      },
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item,
            child: Text(
              _label(item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SharedPresentationStyles.caption,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }

  OutlineInputBorder _dropdownBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  String _label(T value) => itemLabel?.call(value) ?? value.toString();
}
