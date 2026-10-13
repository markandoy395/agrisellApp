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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final actions = [
        _Action(icon: Icons.route_outlined, label: 'Route', onTap: onRoute),
        _Action(icon: Icons.chat_outlined, label: 'Message', onTap: onMessage),
        _Action(icon: Icons.flag_outlined, label: 'Problem', onTap: onProblem),
        _Action(icon: Icons.sos_outlined, label: 'Safety', onTap: onSafety),
        if (onWaybill != null)
          _Action(
            key: const Key('rider-quick-action-waybill'),
            icon: Icons.receipt_long_outlined,
            label: 'Waybill',
            onTap: onWaybill,
          ),
      ];
      final columns =
          constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(12) > 15
          ? 3
          : actions.length;
      final width = (constraints.maxWidth - (columns - 1) * 6) / columns;
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final action in actions) SizedBox(width: width, child: action),
        ],
      );
    },
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
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: RiderDeliveryQuickActionsStyles.outlinedButtonStyle,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(height: 3),
        Text(label, textAlign: TextAlign.center),
      ],
    ),
  );
}
