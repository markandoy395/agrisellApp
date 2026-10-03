import 'package:flutter/material.dart';
import '../styles/farmer_discount_dialog_styles.dart';
import '../controllers/farmer_discount_form_controller.dart';
import 'farmer_discount_product_selector.dart';
import 'farmer_discount_type_choice.dart';
import 'farmer_discount_form_field.dart';
import 'farmer_discount_date_button.dart';

class FarmerDiscountForm extends StatelessWidget {
  const FarmerDiscountForm({
    super.key,
    required this.form,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onSave,
  });
  final FarmerDiscountFormController form;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isEditing = form.isEditing;

    return Container(
      constraints: FarmerDiscountDialogStyles.sheetConstraints(context),
      decoration: FarmerDiscountDialogStyles.sheet,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: FarmerDiscountDialogStyles.dragHandle,
            ),
          ),
          Padding(
            padding: FarmerDiscountDialogStyles.headerPadding,
            child: Row(
              children: [
                Container(
                  padding: FarmerDiscountDialogStyles.offerIconPadding,
                  decoration: FarmerDiscountDialogStyles.offerIcon,
                  child: const Icon(
                    Icons.local_offer_rounded,
                    color: FarmerDiscountDialogStyles.authGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEditing
                        ? 'Edit Promotion'
                        : 'Create Promotion / Discount',
                    style: FarmerDiscountDialogStyles.title,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: FarmerDiscountDialogStyles.bodyPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FarmerDiscountFormField(
                    label: 'Promotion Name',
                    controller: form.nameController,
                    hintText: 'e.g. Weekend Flash Sale, Harvest Promo',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Discount Type',
                    style: FarmerDiscountDialogStyles.fieldLabel,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      FarmerDiscountTypeChoice(
                        label: 'Percentage (%)',
                        isSelected: form.discountType == 'percentage',
                        onTap: () => form.setDiscountType('percentage'),
                      ),
                      const SizedBox(width: 8),
                      FarmerDiscountTypeChoice(
                        label: 'Amount Off (\u20b1)',
                        isSelected: form.discountType == 'amount',
                        onTap: () => form.setDiscountType('amount'),
                      ),
                      const SizedBox(width: 8),
                      FarmerDiscountTypeChoice(
                        label: 'Sale Price (\u20b1)',
                        isSelected: form.discountType == 'sale_price',
                        onTap: () => form.setDiscountType('sale_price'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FarmerDiscountFormField(
                    label: form.discountType == 'percentage'
                        ? 'Discount Percentage (%)'
                        : form.discountType == 'sale_price'
                        ? 'New Sale Price (\u20b1)'
                        : 'Discount Amount (\u20b1)',
                    controller: form.valueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    hintText: form.discountType == 'percentage'
                        ? 'e.g. 15'
                        : 'e.g. 50',
                    prefixText: form.discountType == 'percentage'
                        ? ''
                        : '\u20b1 ',
                    suffixText: form.discountType == 'percentage' ? '%' : '',
                  ),
                  const SizedBox(height: 16),
                  FarmerDiscountFormField(
                    label: 'Promo Code (Optional)',
                    helperText:
                        'Leave blank to automatically apply discount to selected products.',
                    controller: form.promoCodeController,
                    textCapitalization: TextCapitalization.characters,
                    hintText: 'e.g. HARVEST10',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Schedule',
                    style: FarmerDiscountDialogStyles.fieldLabel,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      FarmerDiscountDateButton(
                        date: form.startsAt,
                        placeholder: 'Start Date (Now)',
                        icon: Icons.calendar_today_rounded,
                        onPressed: onPickStartDate,
                      ),
                      const SizedBox(width: 8),
                      FarmerDiscountDateButton(
                        date: form.endsAt,
                        placeholder: 'End Date (Optional)',
                        icon: Icons.event_rounded,
                        onPressed: onPickEndDate,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FarmerDiscountProductSelector(form: form),
                  if (form.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      form.errorMessage!,
                      style: FarmerDiscountDialogStyles.error,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: form.isSaving ? null : onSave,
                      style: FarmerDiscountDialogStyles.saveButton,
                      child: form.isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: FarmerDiscountDialogStyles.white,
                              ),
                            )
                          : Text(
                              isEditing
                                  ? 'Update Promotion'
                                  : 'Save & Apply Discount',
                              style: FarmerDiscountDialogStyles.saveLabel,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
