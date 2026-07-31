import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/utils/agrisellPageRoute.dart';
import 'package:agresell_app/core/utils/responsive.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authBackground.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authButton.dart';
import 'package:agresell_app/features/auth/presentation/widgets/logoHeader.dart';
import 'package:agresell_app/features/auth/presentation/screens/loginScreen.dart';
import 'package:agresell_app/features/auth/presentation/screens/roleSelectionScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: lerpDouble(42, 50, scale),
                ),
                child: _WelcomeCard(scale: scale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        lerpDouble(30, 44, scale),
        lerpDouble(70, 86, scale),
        lerpDouble(30, 44, scale),
        lerpDouble(58, 72, scale),
      ),
      decoration: BoxDecoration(
        color: AgrisellColors.surface.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(
          color: AgrisellColors.surface.withValues(alpha: 0.64),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LogoHeader(
            style: LogoHeaderStyle.mark,
            widthMin: 94,
            widthMax: 116,
          ),
          SizedBox(height: lerpDouble(28, 36, scale)),
          _WelcomeTitle(scale: scale),
          SizedBox(height: lerpDouble(18, 24, scale)),
          Text(
            'Shop fresh harvests from local farmers,\n'
            'reserve orders with confidence,\n'
            'and track every delivery in one place.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: lerpDouble(44, 54, scale)),
          AuthPrimaryButton(
            label: 'Sign In',
            onPressed: () => _open(context, const LoginScreen()),
          ),
          const SizedBox(height: 20),
          AuthOutlinedButton(
            label: 'Sign Up',
            onPressed: () => _open(context, const RoleSelectionScreen.signUp()),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    final route = agrisellPageRoute<void>(builder: (_) => screen);
    Navigator.of(context).pushReplacement(route);
  }
}

class _WelcomeTitle extends StatelessWidget {
  const _WelcomeTitle({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'Welcome to ',
        children: const [
          TextSpan(
            text: 'AgriSell',
            style: TextStyle(
              color: AgrisellColors.authGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AgrisellColors.brandBlack,
        fontSize: 15,
        height: 1.1,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
