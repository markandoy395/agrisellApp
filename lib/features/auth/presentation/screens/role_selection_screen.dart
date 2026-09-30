import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
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
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 720;
    final cardHeight = (size.height * (compact ? .82 : .57))
        .clamp(440.0, 580.0)
        .toDouble();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: compact ? 16 : 22),
                child: LogoHeader(
                  style: LogoHeaderStyle.horizontal,
                  widthMin: size.width * .48,
                  widthMax: size.width * .53,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: cardHeight.clamp(0, size.height).toDouble(),
              child: _RoleSelectionCard(
                submittingRole: _submittingRole,
                onRoleSelected: _selectRole,
              ),
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
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final isSubmitting = submittingRole != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: .09),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 15, 24, 22 + bottomPadding),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AgrisellColors.forestSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Are you a',
                          style: TextStyle(
                            color: AgrisellColors.authGreen,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                        Text(
                          '?',
                          style: TextStyle(
                            color: AgrisellColors.authGreen,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Choose your role to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AgrisellColors.brandBlack,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    RoleButton(
                      label: AuthRole.farmer.label,
                      description: 'Sell your fresh harvests.',
                      icon: Icons.agriculture_outlined,
                      onPressed: isSubmitting
                          ? null
                          : () => onRoleSelected(AuthRole.farmer),
                      isLoading: submittingRole == AuthRole.farmer,
                    ),
                    const SizedBox(height: 10),
                    RoleButton(
                      label: AuthRole.buyer.label,
                      description: 'Shop local produce.',
                      icon: Icons.shopping_cart_outlined,
                      onPressed: isSubmitting
                          ? null
                          : () => onRoleSelected(AuthRole.buyer),
                      isLoading: submittingRole == AuthRole.buyer,
                    ),
                    const SizedBox(height: 10),
                    RoleButton(
                      label: AuthRole.rider.label,
                      description: 'Deliver orders.',
                      icon: Icons.delivery_dining_outlined,
                      onPressed: isSubmitting
                          ? null
                          : () => onRoleSelected(AuthRole.rider),
                      isLoading: submittingRole == AuthRole.rider,
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AgrisellColors.forestSoft),
                    const SizedBox(height: 12),
                    const AuthDescriptionText(
                      text: _description,
                      maxWidth: 360,
                    ),
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
