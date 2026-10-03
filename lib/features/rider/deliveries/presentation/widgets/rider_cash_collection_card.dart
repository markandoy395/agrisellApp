import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_cash_collection_card_styles.dart';
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
          style: SharedPresentationStyles.subtitleExtraBold,
        ),
        const SizedBox(height: 5),
        Text(
          'Collect ${requirement.currencyCode} '
          '${requirement.amountToCollect.toStringAsFixed(2)}',
          style: SharedPresentationStyles.bodyExtraBold,
        ),
        const SizedBox(height: 4),
        Text(
          requirement.remittanceRequired
              ? 'Remittance required after collection.'
              : 'No Rider remittance is required.',
          style: SharedPresentationStyles.caption,
        ),
        if (requirement.riderCashResponsibility.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              requirement.riderCashResponsibility,
              style: SharedPresentationStyles.caption,
            ),
          ),
        if (requirement.paymentNotes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              requirement.paymentNotes,
              style: SharedPresentationStyles.caption,
            ),
          ),
        if (requirement.hasAuthorizedException)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'A server-authorized payment exception permits completion.',
              style: SharedPresentationStyles.captionBold,
            ),
          )
        else ...[
          const SizedBox(height: 10),
          TextField(
            controller: amountController,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: RiderCashCollectionCardStyles.inputDecoration,
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
                style: SharedPresentationStyles.bodyBold,
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
            decoration: RiderCashCollectionCardStyles.inputDecoration2,
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
              decoration: RiderCashCollectionCardStyles.inputDecoration3,
            ),
          ],
        ],
      ],
    ),
  );
}
