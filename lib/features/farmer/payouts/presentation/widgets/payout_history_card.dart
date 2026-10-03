import 'package:flutter/material.dart';

import '../styles/payout_layout_styles.dart';
import '../styles/payout_surface_styles.dart';
import '../styles/payout_text_styles.dart';

class PayoutHistoryCard extends StatelessWidget {
  const PayoutHistoryCard({
    required this.onTap,
    required this.child,
    this.isCashOut = false,
    super.key,
  });

  final VoidCallback onTap;
  final Widget child;
  final bool isCashOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: PayoutSurfaceStyles.historyCard(isCashOut),
      child: InkWell(
        onTap: onTap,
        borderRadius: PayoutSurfaceStyles.cardRadius,
        child: Padding(padding: PayoutLayoutStyles.cardPadding, child: child),
      ),
    );
  }
}

class PayoutStatusBadge extends StatelessWidget {
  const PayoutStatusBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
    super.key,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PayoutLayoutStyles.statusBadgePadding,
      decoration: PayoutSurfaceStyles.statusBadge(backgroundColor),
      child: Text(label, style: PayoutTextStyles.statusLabel(color)),
    );
  }
}
