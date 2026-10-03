import 'package:agresell_app/features/farmer/dashboard/presentation/styles/farmer_sold_status_overlay_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// A compact sold-state treatment for products managed by a farmer.
class FarmerSoldStatusOverlay extends StatelessWidget {
  const FarmerSoldStatusOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: FarmerSoldStatusOverlayStyles.decoratedBoxDecoration,
          child: const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: _FarmerSoldStatusPill(),
            ),
          ),
        ),
      ),
    );
  }
}

class _FarmerSoldStatusPill extends StatelessWidget {
  const _FarmerSoldStatusPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: FarmerSoldStatusOverlayStyles.decoratedBoxDecoration2,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: AgrisellColors.statusRedText,
              size: 14,
            ),
            SizedBox(width: 5),
            Text('Sold', style: FarmerSoldStatusOverlayStyles.soldText),
          ],
        ),
      ),
    );
  }
}
