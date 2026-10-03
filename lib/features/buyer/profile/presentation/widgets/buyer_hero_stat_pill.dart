import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';
import '../styles/profile_header_styles.dart';

class BuyerHeroStatPill extends StatelessWidget {
  const BuyerHeroStatPill({
    required this.value,
    required this.label,
    super.key,
  });

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => BuyerGlassChip(
    padding: ProfileHeaderStyles.statPillPadding,
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$value ',
            style: ProfileHeaderStyles.statPillValue,
          ),
          TextSpan(
            text: label,
            style: ProfileHeaderStyles.statPillLabel,
          ),
        ],
      ),
    ),
  );
}
