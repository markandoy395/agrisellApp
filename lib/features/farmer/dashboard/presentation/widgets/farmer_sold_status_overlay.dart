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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AgrisellColors.brandBlack.withValues(alpha: 0.46),
                AgrisellColors.brandBlack.withValues(alpha: 0.12),
              ],
            ),
          ),
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
      decoration: BoxDecoration(
        color: AgrisellColors.statusRedBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AgrisellColors.statusRedText.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
            Text(
              'Sold',
              style: TextStyle(
                color: AgrisellColors.statusRedText,
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
