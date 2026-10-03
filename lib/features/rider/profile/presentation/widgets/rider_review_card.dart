import 'package:flutter/material.dart';

import '../styles/rider_application_card_styles.dart';

/// Shared shell for application and document review feedback.
class RiderReviewCard extends StatelessWidget {
  const RiderReviewCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
    this.description,
    super.key,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: RiderApplicationCardStyles.cardPadding,
    decoration: RiderApplicationCardStyles.cardDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(title, style: RiderApplicationCardStyles.cardTitle),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 5),
          Text(description!, style: RiderApplicationCardStyles.caption),
        ],
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}
