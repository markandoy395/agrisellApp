import 'package:agresell_app/features/auth/presentation/styles/auth_description_text_styles.dart';
import 'package:flutter/material.dart';

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
          style: AuthDescriptionTextStyles.textText,
        ),
      ),
    );
  }
}
