import 'package:flutter/material.dart';

import '../styles/farmer_profile_header_styles.dart';
import 'farmer_profile_style.dart';

class FarmerProfileStatPill extends StatelessWidget {
  const FarmerProfileStatPill({
    required this.value,
    required this.label,
    super.key,
  });

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => GlassChip(
    padding: FarmerProfileHeaderStyles.statPillPadding,
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$value ',
            style: FarmerProfileHeaderStyles.statValueStyle,
          ),
          TextSpan(
            text: label,
            style: FarmerProfileHeaderStyles.statLabelStyle,
          ),
        ],
      ),
    ),
  );
}
