import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';

class AuthFloatingLabel extends StatelessWidget {
  const AuthFloatingLabel({required this.text, super.key});

  static const floatingLabelKey = Key('auth-floating-label');

  final String text;

  @override
  Widget build(BuildContext context) => Positioned(
    left: 10,
    top: 0,
    child: IgnorePointer(
      child: Container(
        key: floatingLabelKey,
        color: AuthInputStyle.fillColor,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(text, style: AgrisellTheme.floatingInputLabelStyle),
      ),
    ),
  );
}
