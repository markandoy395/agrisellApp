import 'package:agresell_app/features/auth/presentation/styles/auth_divider_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/responsive.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);

    return Row(
      children: [
        const Expanded(
          child: Divider(color: AgrisellColors.dividerLine, thickness: 3),
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: lerpDouble(8, 16, scale)),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: AuthDividerStyles.textText(scale),
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AgrisellColors.dividerLine, thickness: 3),
        ),
      ],
    );
  }
}
