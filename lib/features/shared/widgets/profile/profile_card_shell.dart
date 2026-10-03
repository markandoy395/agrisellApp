import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell_styles.dart';
import 'package:flutter/material.dart';

class ProfileCardShell extends StatelessWidget {
  const ProfileCardShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ProfileCardShellStyles.decoratedBoxDecoration,
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
    );
  }
}
