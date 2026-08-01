import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_progress_timeline.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderHistoryDetailsScreen extends StatelessWidget {
  const RiderHistoryDetailsScreen({required this.entry, super.key});

  final RiderDeliveryHistoryEntry entry;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    body: Column(
      children: [
        RiderPageHeader(
          title: 'Delivery history details',
          subtitle: entry.orderNumber,
          action: IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              color: AgrisellColors.surface,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _section(
                'Product summary',
                '${entry.productName}\n${entry.quantityDescription}',
              ),
              const SizedBox(height: 10),
              _section(
                'Delivery route',
                'Pickup: ${entry.pickupAddress}\n'
                    'Delivery: ${entry.deliveryAddress}',
              ),
              const SizedBox(height: 10),
              _section(
                'Final status',
                '${entry.status.label} • '
                    '${formatRiderDateTime(entry.completedAt)}',
              ),
              const SizedBox(height: 10),
              _section(
                'Proof summary',
                entry.hasProof
                    ? entry.proofTypes.map((type) => type.name).join(', ')
                    : 'No proof attached',
              ),
              if (entry.recipientName?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 10),
                _section('Recipient', entry.recipientName!),
              ],
              if (entry.deliveryNotes?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 10),
                _section('Delivery notes', entry.deliveryNotes!),
              ],
              const SizedBox(height: 10),
              _section(
                'Earning status',
                '${entry.earningStatus.name} • '
                    '${formatRiderCurrency(entry.deliveryFee)}',
              ),
              if (entry.earning case final earning?) ...[
                const SizedBox(height: 10),
                _section(
                  'Final earning breakdown',
                  'Estimated: ${formatRiderCurrency(earning.estimatedEarning)}\n'
                      'Final: ${formatRiderCurrency(earning.finalEarning)}\n'
                      'Waiting: ${formatRiderCurrency(earning.waitingAdjustment)}\n'
                      'Return: ${formatRiderCurrency(earning.returnAdjustment)}\n'
                      'Bonus and incentive: '
                      '${formatRiderCurrency(earning.bonus + earning.incentive)}\n'
                      'Deductions and penalties: '
                      '${formatRiderCurrency(earning.deduction + earning.penalty)}\n'
                      'Net: ${formatRiderCurrency(earning.netEarning)} • '
                      '${earning.payoutStatus.name}',
                ),
              ],
              if (entry.cashCollection case final cash?) ...[
                const SizedBox(height: 10),
                _section(
                  'Cash collection',
                  'Required: ${formatRiderCurrency(cash.amountToCollect)}\n'
                      'Received: ${formatRiderCurrency(cash.amountReceived)}\n'
                      'Status: ${cash.status.name} • '
                      '${cash.remittanceRequired ? 'Remittance required' : 'No remittance'}',
                ),
              ],
              if (entry.timeline.isNotEmpty) ...[
                const SizedBox(height: 12),
                RiderDeliveryProgressTimeline(
                  currentStatus: DeliveryStatus.deliveryCompleted,
                  events: entry.timeline,
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Completed delivery records are read-only.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _section(String title, String value) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value.trim(),
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    ),
  );
}
