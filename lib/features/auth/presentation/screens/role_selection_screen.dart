import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:agresell_app/features/auth/presentation/styles/role_selection_styles.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_background.dart';
import 'package:agresell_app/features/auth/presentation/widgets/logo_header.dart';
import 'package:agresell_app/features/auth/presentation/widgets/role_selection_card.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_sign_up_screen.dart';

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
    final cardHeight = RoleSelectionStyles.cardHeight(size);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(child: AuthBackground()),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: RoleSelectionStyles.headerPadding(compact),
                child: LogoHeader(
                  style: LogoHeaderStyle.horizontal,
                  widthMin: RoleSelectionStyles.logoWidthMin(size.width),
                  widthMax: RoleSelectionStyles.logoWidthMax(size.width),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: cardHeight.clamp(0, size.height).toDouble(),
              child: RoleSelectionCard(
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
