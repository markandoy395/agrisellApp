import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class RiderDeliveryQuickActions extends StatelessWidget {
  const RiderDeliveryQuickActions({
    required this.onRoute,
    required this.onMessage,
    required this.onProblem,
    required this.onSafety,
    super.key,
  });

  final VoidCallback onRoute;
  final VoidCallback onMessage;
  final VoidCallback onProblem;
  final VoidCallback onSafety;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _Action(icon: Icons.route_outlined, label: 'Route', onTap: onRoute),
      const SizedBox(width: 6),
      _Action(icon: Icons.chat_outlined, label: 'Message', onTap: onMessage),
      const SizedBox(width: 6),
      _Action(icon: Icons.flag_outlined, label: 'Problem', onTap: onProblem),
      const SizedBox(width: 6),
      _Action(icon: Icons.sos_outlined, label: 'Safety', onTap: onSafety),
    ],
  );
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: SizedBox(
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AgrisellColors.authGreen,
          side: const BorderSide(color: AgrisellColors.borderLine),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 15), Text(label)],
        ),
      ),
    ),
  );
}
