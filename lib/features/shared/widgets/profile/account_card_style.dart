import 'package:agresell_app/features/shared/widgets/profile/account_card_styles.dart';
import 'package:agresell_app/features/shared/widgets/profile/account_profile_styles.dart';
export 'package:agresell_app/features/shared/widgets/profile/account_profile_styles.dart';
import 'package:flutter/material.dart';

/// Modern elevated card with subtle shadow + border.
class AccountProfileCard extends StatelessWidget {
  const AccountProfileCard({
    required this.child,
    this.color = AccountProfileStyle.surface,
    super.key,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    decoration: AccountCardStyles.containerDecoration(color),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: child,
    ),
  );
}

/// Glassy overlay widget for use inside gradient containers.
class AccountGlassChip extends StatelessWidget {
  const AccountGlassChip({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: AccountCardStyles.containerDecoration2,
    child: child,
  );
}
