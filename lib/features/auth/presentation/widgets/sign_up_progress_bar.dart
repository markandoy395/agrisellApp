import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/presentation/styles/sign_up_screen_styles.dart';

class SignUpProgressBar extends StatelessWidget {
  const SignUpProgressBar({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${step + 1} of 2',
        style: SignUpScreenStyles.stepProgressText,
      ),
      const SizedBox(height: SignUpScreenStyles.stepLabelGap),
      LinearProgressIndicator(
        value: (step + 1) / 2,
        minHeight: SignUpScreenStyles.progressBarHeight,
      ),
    ],
  );
}
