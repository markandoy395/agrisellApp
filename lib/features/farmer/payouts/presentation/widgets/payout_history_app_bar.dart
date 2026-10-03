import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

import '../styles/payout_layout_styles.dart';
import '../styles/payout_surface_styles.dart';
import '../styles/payout_text_styles.dart';

class PayoutHistoryAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PayoutHistoryAppBar({
    required this.onExport,
    required this.onCashOut,
    required this.onRefresh,
    super.key,
  });

  final VoidCallback onExport;
  final VoidCallback onCashOut;
  final VoidCallback onRefresh;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Payout & Disbursement History',
        style: PayoutTextStyles.screenTitle,
      ),
      backgroundColor: AgrisellColors.authGreen,
      foregroundColor: PayoutSurfaceStyles.white,
      elevation: PayoutLayoutStyles.flatElevation,
      actions: [
        IconButton(
          tooltip: 'Export CSV',
          icon: const Icon(Icons.file_download_outlined),
          onPressed: onExport,
        ),
        TextButton.icon(
          onPressed: onCashOut,
          icon: const Icon(
            Icons.payments_rounded,
            size: PayoutLayoutStyles.actionIconSize,
            color: PayoutSurfaceStyles.white,
          ),
          label: const Text('Cash Out', style: PayoutTextStyles.cashOutAction),
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}
