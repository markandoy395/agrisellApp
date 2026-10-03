import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../styles/profile_header_styles.dart';

class BuyerHeroAvatar extends StatelessWidget {
  const BuyerHeroAvatar({
    required this.name,
    required this.isVerified,
    this.showEditBadge = false,
    this.imageBytes,
    this.onEdit,
    super.key,
  });

  final String name;
  final bool isVerified;
  final bool showEditBadge;
  final Uint8List? imageBytes;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: '$name profile avatar',
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // Glow ring
        Container(
          width: ProfileHeaderStyles.avatarSize,
          height: ProfileHeaderStyles.avatarSize,
          decoration: ProfileHeaderStyles.avatarGlowDecoration,
          child: ClipOval(
            child: _avatarImage(),
          ),
        ),
        if (showEditBadge || onEdit != null)
          Positioned(
            right: ProfileHeaderStyles.badgeRightOffset,
            bottom: ProfileHeaderStyles.badgeBottomOffset,
            child: Semantics(
              button: true,
              label: 'Change avatar',
              child: InkWell(
                onTap: onEdit,
                borderRadius: ProfileHeaderStyles.editBadgeRadius,
                child: Container(
                  width: ProfileHeaderStyles.editBadgeSize,
                  height: ProfileHeaderStyles.editBadgeSize,
                  decoration: ProfileHeaderStyles.editBadgeDecoration,
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: ProfileHeaderStyles.badgeIconSize,
                  ),
                ),
              ),
            ),
          )
        else if (isVerified)
          Positioned(
            right: ProfileHeaderStyles.badgeRightOffset,
            bottom: ProfileHeaderStyles.badgeBottomOffset,
            child: Semantics(
              label: 'Verified',
              child: Container(
                width: ProfileHeaderStyles.verifiedBadgeSize,
                height: ProfileHeaderStyles.verifiedBadgeSize,
                decoration: ProfileHeaderStyles.verifiedBadgeDecoration,
                child: const Icon(
                  Icons.check_rounded,
                  color: ProfileHeaderStyles.verifiedBadgeIconColor,
                  size: ProfileHeaderStyles.badgeIconSize,
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _avatarImage() {
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return Image.memory(
        imageBytes!,
        width: ProfileHeaderStyles.avatarSize,
        height: ProfileHeaderStyles.avatarSize,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: ProfileHeaderStyles.avatarSize,
      height: ProfileHeaderStyles.avatarSize,
      decoration: ProfileHeaderStyles.avatarPlaceholderDecoration,
      child: const Icon(
        Icons.person_rounded,
        color: ProfileHeaderStyles.avatarPlaceholderIconColor,
        size: ProfileHeaderStyles.avatarPlaceholderIconSize,
      ),
    );
  }
}
