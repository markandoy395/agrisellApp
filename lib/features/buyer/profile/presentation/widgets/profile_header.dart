import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';
import '../styles/profile_header_styles.dart';
import 'buyer_hero_avatar.dart';
import 'buyer_hero_pattern_painter.dart';
import 'buyer_hero_stat_pill.dart';
import 'buyer_profile_header_top_bar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.profile,
    required this.isVerified,
    this.title = 'Account',
    this.onBack,
    this.onSettingsTap,
    this.showSettingsIcon = false,
    this.followingCount = 0,
    this.followerCount = 0,
    this.showAvatarEditBadge = false,
    this.avatarImageBytes,
    this.onAvatarEdit,
    this.onBasketTap,
    super.key,
  });

  final UserProfile profile;
  final bool isVerified;
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onSettingsTap;
  final bool showSettingsIcon;
  final int followingCount;
  final int followerCount;
  final bool showAvatarEditBadge;
  final Uint8List? avatarImageBytes;
  final VoidCallback? onAvatarEdit;
  final VoidCallback? onBasketTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BuyerProfileHeaderTopBar(
        title: title,
        onBack: onBack,
        onSettingsTap: onSettingsTap,
        showSettingsIcon: showSettingsIcon,
        onBasketTap: onBasketTap,
      ),
      ClipRRect(
        borderRadius: ProfileHeaderStyles.heroBorderRadius,
        child: Container(
          decoration: ProfileHeaderStyles.heroDecoration,
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: BuyerHeroPatternPainter()),
              ),
              Padding(
                padding: ProfileHeaderStyles.heroPadding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BuyerHeroAvatar(
                      name: profile.headerName,
                      isVerified: isVerified,
                      showEditBadge: showAvatarEditBadge,
                      imageBytes: avatarImageBytes,
                      onEdit: onAvatarEdit,
                    ),
                    const SizedBox(width: ProfileHeaderStyles.heroAvatarGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.headerName,
                            style: ProfileHeaderStyles.heroName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height: ProfileHeaderStyles.nameBadgeGap,
                          ),
                          BuyerGlassChip(
                            padding: ProfileHeaderStyles.badgeChipPadding,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isVerified
                                        ? Icons.verified_rounded
                                        : Icons.shopping_bag_outlined,
                                    color:
                                        ProfileHeaderStyles.verifiedIconColor,
                                    size: ProfileHeaderStyles
                                        .verifiedChipIconSize,
                                  ),
                                  const SizedBox(
                                    width: ProfileHeaderStyles.badgeIconGap,
                                  ),
                                  Text(
                                    isVerified
                                        ? 'Verified Buyer'
                                        : 'Buyer Account',
                                    style:
                                        ProfileHeaderStyles.verifiedBadgeText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: ProfileHeaderStyles.badgeFollowersGap,
                          ),
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
                                  spacing: ProfileHeaderStyles.statPillSpacing,
                                  runSpacing:
                                      ProfileHeaderStyles.statPillRunSpacing,
                                  children: [
                                    BuyerHeroStatPill(
                                      value: followingCount,
                                      label: 'Following',
                                    ),
                                    BuyerHeroStatPill(
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
