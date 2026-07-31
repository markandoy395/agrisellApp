part of 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';

class _PricingInventoryFields extends StatelessWidget {
  const _PricingInventoryFields({
    required this.priceController,
    required this.quantityController,
    required this.minimumOrderController,
    required this.unitType,
    required this.errors,
    required this.onPriceChanged,
    required this.onQuantityChanged,
    required this.onMinimumOrderChanged,
    required this.onUnitTypeChanged,
  });

  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TextEditingController minimumOrderController;
  final String unitType;
  final Map<AddProductField, String> errors;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<String> onQuantityChanged;
  final ValueChanged<String> onMinimumOrderChanged;
  final ValueChanged<String?> onUnitTypeChanged;

  @override
  Widget build(BuildContext context) {
    const numberKeyboard = TextInputType.numberWithOptions(decimal: true);
    return Column(
      children: [
        _InputRow(
          label: 'Price / unit *',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _RoundedTextField(
                  controller: priceController,
                  keyboardType: numberKeyboard,
                  textInputAction: TextInputAction.next,
                  prefixText: '\u20B1 ',
                  hintText: '0.00',
                  errorText: errors[AddProductField.price],
                  onChanged: onPriceChanged,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 92,
                child: _CompactDropdown(
                  value: unitType,
                  hint: 'Unit',
                  items: _unitTypes,
                  onChanged: onUnitTypeChanged,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InputRow(
          label: 'Available quantity *',
          child: _RoundedTextField(
            controller: quantityController,
            keyboardType: numberKeyboard,
            textInputAction: TextInputAction.next,
            hintText: '0',
            suffixText: unitType,
            errorText: errors[AddProductField.quantity],
            onChanged: onQuantityChanged,
          ),
        ),
        const SizedBox(height: 14),
        _InputRow(
          label: 'Minimum order *',
          child: _RoundedTextField(
            controller: minimumOrderController,
            keyboardType: numberKeyboard,
            textInputAction: TextInputAction.next,
            hintText: '0',
            suffixText: unitType,
            errorText: errors[AddProductField.minimumOrder],
            onChanged: onMinimumOrderChanged,
          ),
        ),
      ],
    );
  }
}
