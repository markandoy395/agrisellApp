import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderOfflineStateCard extends StatelessWidget {
  const RiderOfflineStateCard({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => RiderEmptyStateCard(
    title: title,
    message: message,
    icon: Icons.cloud_off_outlined,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}
