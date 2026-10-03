import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_delivery_quick_actions_styles.dart';
import 'package:flutter/material.dart';

class RiderDeliveryQuickActions extends StatelessWidget {
  const RiderDeliveryQuickActions({
    required this.onRoute,
    required this.onMessage,
    required this.onProblem,
    required this.onSafety,
    this.onWaybill,
    super.key,
  });

  final VoidCallback onRoute;
  final VoidCallback? onMessage;
  final VoidCallback onProblem;
  final VoidCallback onSafety;
  final VoidCallback? onWaybill;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Action(icon: Icons.route_outlined, label: 'Route', onTap: onRoute),
      const SizedBox(width: 4),
      _Action(icon: Icons.chat_outlined, label: 'Message', onTap: onMessage),
      const SizedBox(width: 4),
      _Action(icon: Icons.flag_outlined, label: 'Problem', onTap: onProblem),
      const SizedBox(width: 4),
      _Action(icon: Icons.sos_outlined, label: 'Safety', onTap: onSafety),
      if (onWaybill != null) ...[
        const SizedBox(width: 4),
        _Action(
          key: const Key('rider-quick-action-waybill'),
          icon: Icons.receipt_long_outlined,
          label: 'Waybill',
          onTap: onWaybill,
        ),
      ],
    ],
  );
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: RiderDeliveryQuickActionsStyles.outlinedButtonStyle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15),
            const SizedBox(height: 1),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    ),
  );
}
