import 'package:agresell_app/features/buyer/home/presentation/styles/farmer_action_buttons_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_follow_button.dart';

class FarmerActions extends StatelessWidget {
  const FarmerActions({
    required this.farmer,
    required this.onChat,
    required this.onShop,
    this.followController,
    super.key,
  });

  final FarmerProfile farmer;
  final VoidCallback onChat;
  final VoidCallback onShop;
  final FarmerFollowController? followController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FarmerFollowButton(
            farmer: farmer,
            controller: followController,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FarmerActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            onPressed: onChat,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _FarmerActionButton(
            icon: Icons.storefront_outlined,
            label: 'Shop',
            isPrimary: true,
            onPressed: onShop,
          ),
        ),
      ],
    );
  }
}

class _FarmerActionButton extends StatelessWidget {
  const _FarmerActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final child = _ActionLabel(
      icon: icon,
      label: label,
      color: isPrimary ? AgrisellColors.surface : AgrisellColors.authGreen,
    );
    return SizedBox(
      height: 38,
      child: isPrimary
          ? FilledButton(
              onPressed: onPressed,
              style: FarmerActionButtonsStyles.filledButtonStyle,
              child: child,
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: FarmerActionButtonsStyles.outlinedButtonStyle,
              child: child,
            ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FarmerActionButtonsStyles.labelText(context, color),
          ),
        ),
      ],
    );
  }
}
