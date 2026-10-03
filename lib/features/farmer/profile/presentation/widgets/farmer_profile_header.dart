import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import '../styles/farmer_profile_header_styles.dart';
import 'farmer_profile_avatar.dart';
import 'farmer_profile_hero_pattern_painter.dart';
import 'farmer_profile_nav_button.dart';
import 'farmer_profile_stat_pill.dart';
import 'farmer_profile_style.dart';

class FarmerProfileHeader extends StatelessWidget {
  const FarmerProfileHeader({
    required this.profile,
    required this.isVerified,
    this.onSettingsTap,
    this.followingCount = 0,
    this.followerCount = 0,
    this.title = 'My Profile',
    this.onBack,
    super.key,
  });

  final UserProfile profile;
  final bool isVerified;
  final VoidCallback? onSettingsTap;
  final int followingCount;
  final int followerCount;
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ── Top bar: back + title + settings ──────────────────────────────
      Padding(
        padding: FarmerProfileHeaderStyles.topBarPadding,
        child: Row(
          children: [
            if (onBack != null) ...[
              FarmerProfileNavButton(
                tooltip: 'Back',
                onPressed: onBack!,
                icon: Icons.arrow_back_ios_new_rounded,
              ),
              FarmerProfileHeaderStyles.spacingNavButton,
            ],
            Expanded(
              child: Text(
                title,
                style: FarmerProfileHeaderStyles.titleStyle,
              ),
            ),
            if (onSettingsTap != null)
              FarmerProfileNavButton(
                tooltip: 'Settings',
                onPressed: onSettingsTap!,
                icon: Icons.tune_rounded,
              ),
          ],
        ),
      ),

      // ── Hero banner ───────────────────────────────────────────────────
      ClipRRect(
        borderRadius: FarmerProfileHeaderStyles.bannerRadius,
        child: Container(
          decoration: FarmerProfileHeaderStyles.heroBannerDecoration,
          child: Stack(
            children: [
              // Decorative background pattern
              const Positioned.fill(
                child: CustomPaint(
                  painter: FarmerProfileHeroPatternPainter(),
                ),
              ),
              // Content
              Padding(
                padding: FarmerProfileHeaderStyles.bannerPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    FarmerProfileAvatar(
                      name: profile.headerName,
                      isVerified: isVerified,
                    ),
                    FarmerProfileHeaderStyles.spacingAvatar,
                    // Name + stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.headerName,
                            style: FarmerProfileHeaderStyles.nameStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isVerified) ...[
                            FarmerProfileHeaderStyles.spacingVerifiedBadge,
                            GlassChip(
                              padding:
                                  FarmerProfileHeaderStyles.verifiedBadgePadding,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified_rounded,
                                      color:
                                          FarmerProfileHeaderStyles.verifiedIconColor,
                                      size:
                                          FarmerProfileHeaderStyles.verifiedIconSize,
                                    ),
                                    FarmerProfileHeaderStyles.spacingVerifiedText,
                                    Text(
                                      'Verified Farmer',
                                      style:
                                          FarmerProfileHeaderStyles.verifiedTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          FarmerProfileHeaderStyles.spacingStats,
                          // Follower chips
                          Semantics(
                            label:
                                '$followingCount following, $followerCount followers',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 0,
                                  height: 0,
                                  child: OverflowBox(
                                    minWidth: 0,
                                    maxWidth: 0,
                                    minHeight: 0,
                                    maxHeight: 0,
                                    child: Text(
                                      '$followingCount Following  |  $followerCount ${followerCount == 1 ? 'Follower' : 'Followers'}',
                                    ),
                                  ),
                                ),
                                Wrap(
                                  spacing:
                                      FarmerProfileHeaderStyles.pillWrapSpacing,
                                  runSpacing:
                                      FarmerProfileHeaderStyles.pillWrapRunSpacing,
                                  children: [
                                    FarmerProfileStatPill(
                                      value: followingCount,
                                      label: 'Following',
                                    ),
                                    FarmerProfileStatPill(
                                      value: followerCount,
                                      label: followerCount == 1
                                          ? 'Follower'
                                          : 'Followers',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
