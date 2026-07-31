import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class AuthDescriptionText extends StatelessWidget {
  const AuthDescriptionText({
    required this.text,
    this.maxWidth = 252,
    super.key,
  });

  final String text;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.18,
          ),
        ),
      ),
    );
  }
}
