import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import '../../domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderCashCollectionCard extends StatelessWidget {
  const RiderCashCollectionCard({
    required this.requirement,
    required this.amountController,
    required this.notesController,
    required this.confirmed,
    required this.issue,
    required this.enabled,
    required this.onConfirmed,
    required this.onIssue,
    super.key,
  });

  final CashOnDeliveryRequirement requirement;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final bool confirmed;
  final CashCollectionIssue? issue;
  final bool enabled;
  final ValueChanged<bool> onConfirmed;
  final ValueChanged<CashCollectionIssue?> onIssue;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cash on delivery',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          'Collect ${requirement.currencyCode} '
          '${requirement.amountToCollect.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          requirement.remittanceRequired
              ? 'Remittance required after collection.'
              : 'No Rider remittance is required.',
          style: const TextStyle(fontSize: 12),
        ),
        if (requirement.riderCashResponsibility.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              requirement.riderCashResponsibility,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        if (requirement.paymentNotes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              requirement.paymentNotes,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        if (requirement.hasAuthorizedException)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'A server-authorized payment exception permits completion.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          )
        else ...[
          const SizedBox(height: 10),
          TextField(
            controller: amountController,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount received'),
          ),
          Material(
            type: MaterialType.transparency,
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: confirmed,
              onChanged: enabled
                  ? (value) => onConfirmed(value ?? false)
                  : null,
              title: const Text(
                'I confirm the cash was collected',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          DropdownButtonFormField<CashCollectionIssue?>(
            dropdownColor: AppDropdownStyle.menuColor,
            borderRadius: AppDropdownStyle.menuBorderRadius,
            style: AppDropdownStyle.textStyle,
            iconEnabledColor: AppDropdownStyle.iconColor,
            initialValue: issue,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Payment issue (optional)',
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text(
                  'No issue',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              for (final value in CashCollectionIssue.values)
                DropdownMenuItem(
                  value: value,
                  child: Text(
                    value.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: enabled ? onIssue : null,
          ),
          if (issue != null) ...[
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              enabled: enabled,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Payment notes'),
            ),
          ],
        ],
      ],
    ),
  );
}
