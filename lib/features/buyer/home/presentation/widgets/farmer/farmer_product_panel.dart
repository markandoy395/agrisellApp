import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_text_styles.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/product_availability_list.dart';

class FarmerProductPanel extends StatelessWidget {
  const FarmerProductPanel({required this.products, super.key});

  final List<ProductAvailability> products;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AgrisellColors.surface,
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, -22),
            child: const _ProductLabel(),
          ),
          Transform.translate(
            offset: const Offset(0, -10),
            child: ProductAvailabilityList(products: products),
          ),
        ],
      ),
    );
  }
}

class _ProductLabel extends StatelessWidget {
  const _ProductLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AgrisellColors.fieldFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AgrisellColors.borderLine, width: 3),
      ),
      child: Text('Product', style: FarmerTextStyles.productLabel(context)),
    );
  }
}
