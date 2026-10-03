import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/styles/role_selection_styles.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_description_text.dart';
import 'package:agresell_app/features/auth/presentation/widgets/role_button.dart';

class RoleSelectionCard extends StatelessWidget {
  const RoleSelectionCard({
    required this.submittingRole,
    required this.onRoleSelected,
    super.key,
  });

  final AuthRole? submittingRole;
  final ValueChanged<AuthRole> onRoleSelected;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final isSubmitting = submittingRole != null;

    return DecoratedBox(
      decoration: RoleSelectionStyles.cardDecoration,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: RoleSelectionStyles.cardPadding(bottomPadding),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 7,
                      decoration: RoleSelectionStyles.indicatorDecoration,
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Are you a', style: RoleSelectionStyles.questionTextStyle),
                        Text('?', style: RoleSelectionStyles.questionTextStyle),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Choose your role to get started.',
                      textAlign: TextAlign.center,
                      style: RoleSelectionStyles.subtitleTextStyle,
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
                      text: RoleSelectionStyles.description,
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
