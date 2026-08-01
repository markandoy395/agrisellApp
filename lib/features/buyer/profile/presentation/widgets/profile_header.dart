import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/common/basket_count_icon_button.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_avatar.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_follow_stats.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.profile,
    required this.onSettingsTap,
    this.followingCount = 0,
    this.followerCount = 0,
    this.showAvatarEditBadge = false,
    this.avatarImageBytes,
    this.onAvatarEdit,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onSettingsTap;
  final int followingCount;
  final int followerCount;
  final bool showAvatarEditBadge;
  final Uint8List? avatarImageBytes;
  final VoidCallback? onAvatarEdit;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final headerTopPadding = (topInset > 0 ? topInset : 24.0) + 14;
    final horizontalPadding = width < 380 ? 14.0 : 18.0;
    final headerBottomPadding = width < 380 ? 10.0 : 12.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        headerTopPadding,
        horizontalPadding,
        headerBottomPadding,
      ),
      decoration: const BoxDecoration(
        color: AgrisellColors.authGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Row(
        children: [
          ProfileAvatar(
            displayName: profile.headerName,
            showEditBadge: showAvatarEditBadge,
            imageBytes: avatarImageBytes,
            onEdit: onAvatarEdit,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profile.headerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ProfileTextStyles.username(context),
                ),
                const SizedBox(height: 5),
                ProfileFollowStats(
                  followingCount: followingCount,
                  followerCount: followerCount,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: BasketController.instance,
                builder: (context, _) {
                  final controller = BasketController.instance;
                  return BasketCountIconButton(
                    count: controller.totalQuantity,
                    pulse: controller.pulse,
                    iconColor: AgrisellColors.surface,
                    iconSize: 26,
                    tapSize: 38,
                    inkRadius: 24,
                    badgeColor: AgrisellColors.surface,
                    badgeTextColor: AgrisellColors.authGreen,
                    badgeBorderColor: AgrisellColors.authGreen,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AgrisellRoutes.basket),
                  );
                },
              ),
              const SizedBox(width: 10),
              _HeaderIconButton(
                semanticLabel: 'Settings',
                onTap: onSettingsTap,
                child: const Icon(
                  Icons.settings,
                  color: AgrisellColors.surface,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(onTap: onTap, radius: 24, child: child),
    );
  }
}
