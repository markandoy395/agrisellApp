import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_follow_stats.dart';

class FarmerProfileHeader extends StatelessWidget {
  const FarmerProfileHeader({
    required this.profile,
    required this.isVerified,
    required this.onSettingsTap,
    this.followingCount = 0,
    this.followerCount = 0,
    super.key,
  });

  final UserProfile profile;
  final bool isVerified;
  final VoidCallback onSettingsTap;
  final int followingCount;
  final int followerCount;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final horizontalPadding = width < 380 ? 18.0 : 22.0;
    final headerTopPadding = (topInset > 0 ? topInset : 24.0) + 15;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        headerTopPadding,
        horizontalPadding,
        17,
      ),
      decoration: const BoxDecoration(
        color: AgrisellColors.authGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Row(
        children: [
          _FarmerAvatar(
            displayName: profile.headerName,
            isVerified: isVerified,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: _FarmerHeaderText(
              profile: profile,
              followingCount: followingCount,
              followerCount: followerCount,
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Open farmer settings',
            child: IconButton(
              tooltip: 'Settings',
              onPressed: onSettingsTap,
              icon: const Icon(
                Icons.settings,
                color: AgrisellColors.surface,
                size: 27,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmerAvatar extends StatelessWidget {
  const _FarmerAvatar({required this.displayName, required this.isVerified});

  final String displayName;
  final bool isVerified;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: '$displayName profile avatar',
    child: SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AgrisellColors.fieldFill,
              shape: BoxShape.circle,
              border: Border.all(color: AgrisellColors.surface, width: 2),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AgrisellColors.authGreen,
              size: 30,
            ),
          ),
          if (isVerified)
            const Positioned(right: -5, top: 18, child: _FarmerVerifiedBadge()),
        ],
      ),
    ),
  );
}

class _FarmerHeaderText extends StatelessWidget {
  const _FarmerHeaderText({
    required this.profile,
    required this.followingCount,
    required this.followerCount,
  });

  final UserProfile profile;
  final int followingCount;
  final int followerCount;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        profile.headerName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AgrisellColors.surface,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      if (profile.address.isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(
          profile.address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AgrisellColors.surface.withValues(alpha: 0.88),
            fontSize: 12,
          ),
        ),
      ],
      const SizedBox(height: 5),
      ProfileFollowStats(
        followingCount: followingCount,
        followerCount: followerCount,
      ),
    ],
  );
}

class _FarmerVerifiedBadge extends StatelessWidget {
  const _FarmerVerifiedBadge();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Verified farmer',
    child: const Tooltip(
      message: 'Verified farmer',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AgrisellColors.surface,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(2),
          child: Icon(
            Icons.verified_rounded,
            color: AgrisellColors.authGreen,
            size: 18,
          ),
        ),
      ),
    ),
  );
}
