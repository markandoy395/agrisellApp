import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';

class FarmerStatsCard extends StatelessWidget {
  const FarmerStatsCard({super.key});

  @override
  Widget build(BuildContext context) => const ProfileCardShell(
    child: Padding(
      padding: EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(
            Icons.query_stats_outlined,
            color: AgrisellColors.authGreen,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sales statistics will appear after the backend returns your farm data.',
              style: TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
