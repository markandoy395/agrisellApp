import 'package:flutter/material.dart';

import '../styles/rider_application_card_styles.dart';

/// Common heading and body layout with predefined review style variants.
class RiderReviewSection extends StatelessWidget {
  const RiderReviewSection({
    required this.title,
    required this.icon,
    required this.variant,
    required this.children,
    super.key,
  });

  final String title;
  final IconData icon;
  final RiderReviewSectionVariant variant;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: RiderApplicationCardStyles.sectionPadding,
    decoration: RiderApplicationCardStyles.sectionDecoration(variant),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: variant == RiderReviewSectionVariant.missingItems ? 18 : 16,
              color: RiderApplicationCardStyles.sectionColor(variant),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: RiderApplicationCardStyles.sectionHeading(variant),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...children,
      ],
    ),
  );
}
