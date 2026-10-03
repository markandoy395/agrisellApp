import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';
import '../../styles/home_banner_styles.dart';

class HomeBannerExpiryBadge extends StatelessWidget {
  const HomeBannerExpiryBadge({
    required this.banner,
    required this.compact,
    super.key,
  });
  final HomeBanner banner;
  final bool compact;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Valid until ${banner.expiryLabel}',
    excludeSemantics: true,
    child: Container(
      padding: HomeBannerStyles.expiryPadding(compact),
      decoration: HomeBannerStyles.expiryDecoration,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 17 : 19,
            height: compact ? 17 : 19,
            decoration: HomeBannerStyles.expiryIconDecoration,
            child: Icon(
              Icons.calendar_month_rounded,
              color: AgrisellColors.surface,
              size: compact ? 11 : 12,
            ),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VALID UNTIL',
                style: HomeBannerStyles.expiryCaption(compact),
              ),
              const SizedBox(height: 2),
              Text(
                banner.expiryLabel,
                style: HomeBannerStyles.expiryDate(compact),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
