part of 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';

class _InventoryLotFields extends StatelessWidget {
  const _InventoryLotFields({
    required this.dateType,
    required this.allowedDateTypes,
    required this.harvestedAt,
    required this.marketableUntil,
    required this.lotCodeController,
    required this.storageInstructionsController,
    required this.errors,
    required this.onDateTypeChanged,
    required this.onSelectHarvestDate,
    required this.onSelectMarketableUntil,
    required this.onLotCodeChanged,
    required this.onStorageChanged,
  });

  final ProductInventoryDateType dateType;
  final List<ProductInventoryDateType> allowedDateTypes;
  final DateTime? harvestedAt;
  final DateTime? marketableUntil;
  final TextEditingController lotCodeController;
  final TextEditingController storageInstructionsController;
  final Map<AddProductField, String> errors;
  final ValueChanged<ProductInventoryDateType?> onDateTypeChanged;
  final VoidCallback onSelectHarvestDate;
  final VoidCallback onSelectMarketableUntil;
  final ValueChanged<String> onLotCodeChanged;
  final ValueChanged<String> onStorageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InputRow(
          label: 'Product type *',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CompactDropdown(
                value: dateType,
                hint: 'Select product type',
                items: allowedDateTypes,
                itemLabel: (value) => value.farmerLabel,
                onChanged: onDateTypeChanged,
              ),
              const SizedBox(height: 6),
              Text(
                dateType.guidance,
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        if (dateType != ProductInventoryDateType.nonPerishable) ...[
          const SizedBox(height: 14),
          _LotDateField(
            key: const Key('product-lot-harvest-date'),
            label: 'Harvested/produced *',
            value: harvestedAt,
            errorText: errors[AddProductField.lotHarvestDate],
            onPressed: onSelectHarvestDate,
          ),
          const SizedBox(height: 14),
          _LotDateField(
            key: const Key('product-lot-marketable-until'),
            label: dateType == ProductInventoryDateType.packagedFood
                ? 'Expiration date *'
                : 'Sell until *',
            value: marketableUntil,
            errorText: errors[AddProductField.marketableUntil],
            onPressed: onSelectMarketableUntil,
          ),
        ],
        if (dateType == ProductInventoryDateType.packagedFood) ...[
          const SizedBox(height: 14),
          _InputRow(
            label: 'Lot code *',
            child: _RoundedTextField(
              controller: lotCodeController,
              hintText: 'Copy from package',
              maxLength: 80,
              errorText: errors[AddProductField.lotCode],
              onChanged: onLotCodeChanged,
            ),
          ),
        ],
        const SizedBox(height: 14),
        _InputRow(
          label: 'Storage',
          child: _RoundedTextField(
            controller: storageInstructionsController,
            hintText: 'Example: Keep refrigerated',
            maxLength: 240,
            maxLines: 2,
            errorText: errors[AddProductField.storageInstructions],
            onChanged: onStorageChanged,
          ),
        ),
      ],
    );
  }
}

class _LotDateField extends StatelessWidget {
  const _LotDateField({
    super.key,
    required this.label,
    required this.value,
    required this.errorText,
    required this.onPressed,
  });

  final String label;
  final DateTime? value;
  final String? errorText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _InputRow(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: Text(
                value == null ? 'Choose date' : _formatLotDate(value!),
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                foregroundColor: AgrisellColors.authGreen,
                side: BorderSide(
                  color: errorText == null
                      ? AgrisellColors.borderLine
                      : AgrisellColors.statusRedText,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: const TextStyle(
                color: AgrisellColors.statusRedText,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatLotDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';
