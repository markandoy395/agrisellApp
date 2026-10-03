import 'package:flutter/material.dart';
import '../styles/farmer_discount_dialog_styles.dart';
import '../controllers/farmer_discount_form_controller.dart';

class FarmerDiscountProductSelector extends StatelessWidget {
  const FarmerDiscountProductSelector({super.key, required this.form});
  final FarmerDiscountFormController form;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text(
            'Apply to Products',
            style: FarmerDiscountDialogStyles.fieldLabel,
          ),
          const Spacer(),
          if (form.products.isNotEmpty)
            TextButton(
              onPressed: form.toggleAllProducts,
              child: Text(
                form.allProductsSelected ? 'Deselect All' : 'Select All',
                style: FarmerDiscountDialogStyles.selectAll,
              ),
            ),
        ],
      ),
      const SizedBox(height: 6),
      if (form.products.isEmpty)
        const Text(
          'No products available to discount.',
          style: FarmerDiscountDialogStyles.helper,
        )
      else
        Container(
          decoration: FarmerDiscountDialogStyles.products,
          child: Material(
            type: MaterialType.transparency,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: form.products.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = form.products[index];
                final id = product.commodityId;
                final isSelected =
                    id != null && form.selectedCommodityIds.contains(id);

                return CheckboxListTile(
                  value: isSelected,
                  activeColor: FarmerDiscountDialogStyles.authGreen,
                  title: Text(
                    product.name,
                    style: FarmerDiscountDialogStyles.productName,
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'Base: ${product.price}',
                        style: FarmerDiscountDialogStyles.helper,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 11,
                          color: FarmerDiscountDialogStyles.authGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sale: ${form.previewPrice(product)}',
                          style: FarmerDiscountDialogStyles.preview,
                        ),
                      ],
                    ],
                  ),
                  onChanged: id == null
                      ? null
                      : (selected) => form.selectProduct(id, selected == true),
                );
              },
            ),
          ),
        ),
    ],
  );
}
