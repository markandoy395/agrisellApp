import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_section_label.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class FarmerHistoryCard extends StatelessWidget {
  const FarmerHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCardShell(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Row(
              children: [
                const ProfileSectionLabel(text: 'My history'),
                const Spacer(),
                TextButton(
                  onPressed: () => _openToShip(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AgrisellColors.brandBlack,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: const Size(0, 32),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All Orders',
                        style: ProfileTextStyles.cardAction(context).copyWith(
                          color: AgrisellColors.brandBlack.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AgrisellColors.brandBlack.withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                children: [
                  Expanded(
                    child: HistoryShortcut(
                      label: 'To Ship',
                      icon: Icons.format_list_bulleted_rounded,
                      opensToShip: true,
                    ),
                  ),
                  Expanded(
                    child: HistoryShortcut(
                      label: 'Completed',
                      icon: Icons.assignment_turned_in_outlined,
                    ),
                  ),
                  Expanded(
                    child: HistoryShortcut(
                      label: 'Feedback',
                      icon: Icons.rate_review_outlined,
                    ),
                  ),
                  Expanded(
                    child: HistoryShortcut(
                      label: 'Confirm',
                      icon: Icons.verified_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openToShip(BuildContext context) {
    Navigator.of(context).pushNamed(AgrisellRoutes.toShip);
  }
}

class HistoryShortcut extends StatelessWidget {
  const HistoryShortcut({
    required this.label,
    required this.icon,
    this.opensToShip = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool opensToShip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: opensToShip
            ? () => Navigator.of(context).pushNamed(AgrisellRoutes.toShip)
            : () {},
        radius: 27,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AgrisellColors.authGreen, size: 28),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: ProfileTextStyles.orderLabel(context),
            ),
          ],
        ),
      ),
    );
  }
}
