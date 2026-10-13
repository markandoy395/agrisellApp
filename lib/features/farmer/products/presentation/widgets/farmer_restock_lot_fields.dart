import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/farmer/products/presentation/styles/farmer_restock_lot_fields_styles.dart';
import 'package:flutter/material.dart';
import '../styles/farmer_restock_dialog_styles.dart';

import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';

class FarmerRestockLotFields extends StatelessWidget {
  const FarmerRestockLotFields({
    required this.dateType,
    required this.allowedDateTypes,
    required this.harvestedAt,
    required this.marketableUntil,
    required this.lotCodeController,
    required this.storageController,
    required this.errors,
    required this.onDateTypeChanged,
    required this.onSelectHarvestDate,
    required this.onSelectMarketableUntil,
    super.key,
  });

  final ProductInventoryDateType dateType;
  final List<ProductInventoryDateType> allowedDateTypes;
  final DateTime? harvestedAt;
  final DateTime? marketableUntil;
  final TextEditingController lotCodeController;
  final TextEditingController storageController;
  final Map<String, String> errors;
  final ValueChanged<ProductInventoryDateType?> onDateTypeChanged;
  final VoidCallback onSelectHarvestDate;
  final VoidCallback onSelectMarketableUntil;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Batch freshness'),
        const SizedBox(height: 7),
        DropdownButtonFormField<ProductInventoryDateType>(
          key: const Key('restock-date-type-field'),
          initialValue: dateType,
          isExpanded: true,
          style: FarmerRestockLotFieldsStyles.dropdownTextStyle,
          items: [
            for (final type in allowedDateTypes)
              DropdownMenuItem(value: type, child: Text(type.farmerLabel)),
          ],
          onChanged: onDateTypeChanged,
          decoration: _decoration(),
        ),
        const SizedBox(height: 6),
        Text(
          dateType.guidance,
          style: FarmerRestockLotFieldsStyles.guidanceStyle,
        ),
        if (dateType != ProductInventoryDateType.nonPerishable) ...[
          const SizedBox(height: 12),
          _DateButton(
            buttonKey: const Key('restock-harvest-date-field'),
            label: 'Harvested or produced',
            value: harvestedAt,
            errorText: errors['harvestedAt'],
            onPressed: onSelectHarvestDate,
          ),
          const SizedBox(height: 12),
          _DateButton(
            buttonKey: const Key('restock-marketable-until-field'),
            label: dateType == ProductInventoryDateType.packagedFood
                ? 'Printed expiration date'
                : 'Sell until',
            value: marketableUntil,
            errorText: errors['sellUntil'] ?? errors['expiresAt'],
            onPressed: onSelectMarketableUntil,
          ),
        ],
        if (dateType == ProductInventoryDateType.packagedFood) ...[
          const SizedBox(height: 12),
          const _FieldLabel('Lot or batch code'),
          const SizedBox(height: 7),
          TextField(
            key: const Key('restock-lot-code-field'),
            controller: lotCodeController,
            maxLength: 80,
            decoration: _decoration(
              hintText: 'Copy from the package',
              errorText: errors['lotCode'],
            ),
          ),
        ],
        const SizedBox(height: 12),
        const _FieldLabel('Storage instructions (optional)'),
        const SizedBox(height: 7),
        TextField(
          key: const Key('restock-storage-field'),
          controller: storageController,
          maxLength: 240,
          maxLines: 2,
          style: FarmerRestockDialogStyles.inputTextStyle,
          decoration: _decoration(
            hintText: 'Example: Keep refrigerated',
            errorText: errors['storageInstructions'],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: FarmerRestockDialogStyles.fieldLabelStyle);
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.buttonKey,
    required this.label,
    required this.value,
    required this.errorText,
    required this.onPressed,
  });

  final Key buttonKey;
  final String label;
  final DateTime? value;
  final String? errorText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FieldLabel(label),
      const SizedBox(height: 7),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          key: buttonKey,
          onPressed: onPressed,
          icon: const Icon(Icons.calendar_month_outlined, size: 22),
          label: Text(value == null ? 'Select date' : _displayDate(value!)),
          style: FarmerRestockLotFieldsStyles.outlinedButtonStyle(errorText),
        ),
      ),
      if (errorText != null) ...[
        const SizedBox(height: 5),
        Text(errorText!, style: SharedPresentationStyles.errorCaption),
      ],
    ],
  );
}

InputDecoration _decoration({String? hintText, String? errorText}) =>
    FarmerRestockLotFieldsStyles.inputDecoration(hintText, errorText);

String _displayDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
