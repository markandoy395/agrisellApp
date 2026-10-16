import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_map_nav_styles.dart';

class RiderNavActionButtons extends StatelessWidget {
  const RiderNavActionButtons({
    this.onCall,
    this.onMessage,
    this.onProblem,
    this.onMore,
    this.onManageDelivery,
    super.key,
  });

  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onProblem;
  final VoidCallback? onMore;
  final VoidCallback? onManageDelivery;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          _tile(
            icon: Icons.phone_rounded,
            color: AgrisellColors.statusBlueText,
            label: 'Call',
            onTap: onCall,
          ),
          const SizedBox(width: 8),
          _tile(
            icon: Icons.chat_bubble_outline_rounded,
            color: AgrisellColors.statusBlueText,
            label: 'Message',
            onTap: onMessage,
          ),
          const SizedBox(width: 8),
          _tile(
            icon: Icons.warning_amber_rounded,
            color: AgrisellColors.statusRedText,
            label: 'Problem',
            onTap: onProblem,
          ),
          const SizedBox(width: 8),
          _tile(
            icon: Icons.more_horiz_rounded,
            color: AgrisellColors.mutedText,
            label: 'More',
            onTap: onMore,
          ),
        ],
      ),
      if (onManageDelivery != null) ...[
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onManageDelivery,
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('Manage delivery'),
          ),
        ),
      ],
    ],
  );

  Widget _tile({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback? onTap,
  }) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: RiderMapNavStyles.actionTile,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: RiderMapNavStyles.actionLabel),
          ],
        ),
      ),
    ),
  );
}
