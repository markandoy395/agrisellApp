import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/utils/responsive.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_background.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_description_text.dart';
import 'package:agresell_app/features/auth/presentation/widgets/logo_header.dart';
import 'package:agresell_app/features/auth/presentation/widgets/role_button.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_sign_up_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen.signUp({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  AuthRole? _submittingRole;

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(height: lerpDouble(78, 96, scale)),
                const LogoHeader(
                  style: LogoHeaderStyle.horizontal,
                  widthMin: 218,
                  widthMax: 260,
                ),
                SizedBox(height: lerpDouble(32, 40, scale)),
                Expanded(
                  child: _RoleSelectionCard(
                    submittingRole: _submittingRole,
                    onRoleSelected: _selectRole,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectRole(AuthRole role) {
    if (_submittingRole != null) {
      return;
    }

    setState(() => _submittingRole = role);

    Navigator.of(context).pushReplacement(
      agrisellPageRoute<void>(
        builder: (_) => switch (role) {
          AuthRole.rider => const RiderSignUpScreen(),
          AuthRole.farmer => const FarmerSignUpScreen(),
          _ => SignUpScreen(role: role),
        },
      ),
    );
  }
}

class _RoleSelectionCard extends StatelessWidget {
  const _RoleSelectionCard({
    required this.submittingRole,
    required this.onRoleSelected,
  });

  final AuthRole? submittingRole;
  final ValueChanged<AuthRole> onRoleSelected;

  static const _description =
      'Choose Farmer if you want to sell fresh harvests. Choose Buyer if you '
      'want to shop local produce, or Rider if you deliver orders.';

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final isSubmitting = submittingRole != null;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(46)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  lerpDouble(44, 56, scale),
                  lerpDouble(74, 88, scale),
                  lerpDouble(44, 56, scale),
                  28 + bottomPadding,
                ),
                child: Column(
                  children: [
                    Text(
                      'Are you a',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AgrisellColors.authGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 18),
                    RoleButton(
                      label: AuthRole.farmer.label,
                      onPressed: isSubmitting
                          ? null
                          : () => onRoleSelected(AuthRole.farmer),
                      isLoading: submittingRole == AuthRole.farmer,
                    ),
                    const SizedBox(height: 13),
                    RoleButton(
                      label: AuthRole.buyer.label,
                      onPressed: isSubmitting
                          ? null
                          : () => onRoleSelected(AuthRole.buyer),
                      isLoading: submittingRole == AuthRole.buyer,
                    ),
                    const SizedBox(height: 13),
                    RoleButton(
                      label: AuthRole.rider.label,
                      onPressed: isSubmitting
                          ? null
                          : () => onRoleSelected(AuthRole.rider),
                      isLoading: submittingRole == AuthRole.rider,
                    ),
                    SizedBox(height: lerpDouble(28, 34, scale)),
                    const AuthDescriptionText(text: _description),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
