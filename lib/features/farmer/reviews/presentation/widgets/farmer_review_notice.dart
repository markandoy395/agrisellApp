import 'package:flutter/material.dart';

import '../styles/farmer_reviews_styles.dart';
import '../styles/farmer_review_notice_styles.dart';

class FarmerReviewNotice extends StatelessWidget {
  const FarmerReviewNotice({
    required this.title,
    required this.icon,
    required this.style,
    this.body,
    this.expandTitle = false,
    super.key,
  });

  final String title;
  final IconData icon;
  final FarmerReviewNoticeStyle style;
  final String? body;
  final bool expandTitle;

  @override
  Widget build(BuildContext context) {
    final titleText = Text(title, style: style.title);

    return Container(
      padding: style.padding,
      decoration: style.decoration,
      child: Column(
        crossAxisAlignment: FarmerReviewsStyles.alignStart,
        children: [
          Row(
            children: [
              Icon(icon, size: style.iconSize, color: style.iconColor),
              SizedBox(width: style.titleGap),
              if (expandTitle) Expanded(child: titleText) else titleText,
            ],
          ),
          if (body != null) ...[
            const SizedBox(height: FarmerReviewsStyles.smallGap),
            Text(body!, style: style.body),
          ],
        ],
      ),
    );
  }
}
