import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/deals/presentation/styles/deals_and_promos_screen_styles.dart';

class DealsEmptyView extends StatelessWidget {
  const DealsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 60),
        Icon(
          Icons.confirmation_number_outlined,
          size: DealsAndPromosScreenStyles.emptyIconSize,
          color: AgrisellColors.borderLine,
        ),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No active vouchers found',
            style: DealsAndPromosScreenStyles.emptyTitleStyle,
          ),
        ),
        SizedBox(height: 6),
        Center(
          child: Padding(
            padding: DealsAndPromosScreenStyles.emptyMessagePadding,
            child: Text(
              'Check back soon! New promotional deals and vouchers are added regularly.',
              textAlign: TextAlign.center,
              style: DealsAndPromosScreenStyles.emptyMessageStyle,
            ),
          ),
        ),
      ],
    );
  }
}
