import 'package:agresell_app/features/auth/presentation/styles/auth_bottom_link_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/responsive.dart';

class AuthBottomLink extends StatelessWidget {
  const AuthBottomLink({
    required this.label,
    required this.action,
    required this.onTap,
    super.key,
  });

  final String label;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);

    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 32,
        children: [
          Text(label, style: AuthBottomLinkStyles.labelText(scale)),
          TextButton(
            onPressed: onTap,
            style: AuthBottomLinkStyles.textButtonStyle(scale),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
