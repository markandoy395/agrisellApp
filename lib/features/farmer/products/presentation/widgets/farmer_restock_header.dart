import 'package:flutter/material.dart';

import '../styles/farmer_restock_dialog_styles.dart';

class FarmerRestockHeader extends StatelessWidget {
  const FarmerRestockHeader({
    required this.productName,
    super.key,
  });

  final String productName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: FarmerRestockDialogStyles.headerIconBoxSize,
          height: FarmerRestockDialogStyles.headerIconBoxSize,
          decoration: FarmerRestockDialogStyles.headerIconBoxDecoration,
          child: const Icon(
            Icons.inventory_2_outlined,
            color: FarmerRestockDialogStyles.headerIconColor,
            size: FarmerRestockDialogStyles.headerIconSize,
          ),
        ),
        FarmerRestockDialogStyles.spacingHeaderIcon,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add stock',
                style: FarmerRestockDialogStyles.headerTitleStyle,
              ),
              FarmerRestockDialogStyles.spacingHeaderTitle,
              Text(
                productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FarmerRestockDialogStyles.headerSubtitleStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
