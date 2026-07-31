import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: lerpDouble(12, 14, scale),
              fontWeight: FontWeight.w400,
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
