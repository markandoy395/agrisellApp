import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import '../styles/payout_layout_styles.dart';
import '../styles/payout_surface_styles.dart';
import '../styles/payout_text_styles.dart';

class PayoutReferenceRow extends StatelessWidget {
  const PayoutReferenceRow({required this.reference, super.key});

  final String reference;

  void _copyReference(BuildContext context, String reference) {
    if (reference.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: reference.trim()));
    ScaffoldMessenger.of(context).showAppSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Payout reference copied to clipboard.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PayoutLayoutStyles.referencePadding,
      decoration: PayoutSurfaceStyles.reference,
      child: Row(
        mainAxisAlignment: PayoutLayoutStyles.spaceBetween,
        children: [
          Text('Ref: $reference', style: PayoutTextStyles.referenceLabel),
          InkWell(
            onTap: () => _copyReference(context, reference),
            child: const Padding(
              padding: PayoutLayoutStyles.copyIconPadding,
              child: Icon(
                Icons.copy_rounded,
                size: PayoutLayoutStyles.copyIconSize,
                color: AgrisellColors.authGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
