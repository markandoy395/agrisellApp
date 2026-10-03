import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_follow_stats_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class ProfileFollowStats extends StatelessWidget {
  const ProfileFollowStats({
    this.followingCount = 0,
    this.followerCount = 0,
    this.foregroundColor = AgrisellColors.surface,
    super.key,
  });

  final int followingCount;
  final int followerCount;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$followingCount following, $followerCount followers',
      child: ExcludeSemantics(
        child: Wrap(
          spacing: 12,
          runSpacing: 2,
          children: [
            _FollowStat(
              count: followingCount,
              label: 'Following',
              foregroundColor: foregroundColor,
            ),
            _FollowStat(
              count: followerCount,
              label: 'Followers',
              foregroundColor: foregroundColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowStat extends StatelessWidget {
  const _FollowStat({
    required this.count,
    required this.label,
    required this.foregroundColor,
  });

  final int count;
  final String label;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${count < 0 ? 0 : count} ',
            style: SharedPresentationStyles.extraBold,
          ),
          TextSpan(text: label),
        ],
      ),
      maxLines: 1,
      style: ProfileFollowStatsStyles.textStyle(foregroundColor),
    );
  }
}
