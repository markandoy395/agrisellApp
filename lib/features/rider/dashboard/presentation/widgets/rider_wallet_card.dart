import 'package:flutter/material.dart';
import '../controllers/rider_analytics_controller.dart';
import '../styles/rider_earnings_styles.dart';
import '../../../presentation/widgets/rider_page_widgets.dart';
import 'rider_analytics_formatters.dart';

class RiderWalletCard extends StatelessWidget {
  const RiderWalletCard({
    required this.controller,
    required this.onRetry,
    super.key,
  });
  final RiderAnalyticsController controller;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final wallet = controller.wallet;
    return RiderSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cash-out balance (all time)',
            style: RiderEarningsStyles.netEarningsSubtextStyle,
          ),
          if (wallet != null) ...[
            if (wallet.reconciliationRequired)
              const Text(
                'An earlier payout needs admin reconciliation. '
                'Cash out is paused to prevent duplicate payment.',
              ),
            Text(
              formatRiderCurrency(wallet.available),
              style: RiderEarningsStyles.netEarningsStyle,
            ),
            Text(
              'Reserved: ${formatRiderCurrency(wallet.reserved)} · '
              'Paid: ${formatRiderCurrency(wallet.paid)}',
            ),
          ] else ...[
            Text(controller.walletError ?? 'Loading verified balance…'),
            TextButton(
              onPressed: onRetry,
              child: const Text('Refresh balance'),
            ),
          ],
          const Text(
            'Requests reserve your balance until paid or rejected. '
            'Admin records the transfer after sending it through GCash or your bank.',
          ),
          if (controller.withdrawalRequests.isNotEmpty) ...[
            const Divider(),
            const Text('Cash-out history'),
            for (final request in controller.withdrawalRequests)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${formatRiderCurrency(request.amount)} · ${request.statusLabel}',
                ),
                subtitle: Text(
                  [
                    request.methodLabel,
                    if (request.payoutReference.isNotEmpty)
                      'Reference: ${request.payoutReference}',
                    if (request.rejectionReason.isNotEmpty)
                      request.rejectionReason,
                  ].join('\n'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
