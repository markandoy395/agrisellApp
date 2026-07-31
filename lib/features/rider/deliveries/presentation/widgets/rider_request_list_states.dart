import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

Widget riderRequestEmptyState(RiderDeliveryController controller) {
  final hasSearch = controller.searchText.isNotEmpty;
  final hasFilters = controller.requestFilters.activeCount > 0;
  return RiderEmptyStateCard(
    title: hasSearch
        ? 'No search results'
        : hasFilters
        ? 'No requests match these filters'
        : 'No compatible nearby requests',
    message: hasSearch || hasFilters
        ? 'Clear the search or reset filters to broaden the results.'
        : 'Ready-to-pickup orders will appear after the backend returns an eligible match.',
    actionLabel: hasFilters ? 'Reset filters' : null,
    onAction: hasFilters ? controller.resetRequestFilters : null,
    icon: Icons.local_shipping_outlined,
  );
}

Widget riderRequestDataNotice(RiderDeliveryController controller) => Column(
  children: [
    if (controller.loadState == RiderRequestLoadState.loading) ...[
      const LinearProgressIndicator(),
      const SizedBox(height: 8),
    ],
    if (controller.usesTemporaryData)
      const Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            'Delivery backend unavailable. No local requests are generated.',
            style: TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
  ],
);

Widget centerRiderRequestContent(Widget child) => Center(
  child: SingleChildScrollView(padding: const EdgeInsets.all(22), child: child),
);
