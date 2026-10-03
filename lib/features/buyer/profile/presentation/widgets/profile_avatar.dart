import 'package:agresell_app/features/buyer/profile/presentation/styles/profile_avatar_styles.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/navigation/home_asset_icon.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.displayName,
    required this.showEditBadge,
    this.imageBytes,
    this.onEdit,
    super.key,
  });

  final String displayName;
  final bool showEditBadge;
  final Uint8List? imageBytes;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final bytes = imageBytes;
    final decodedAvatarSize = (48 * MediaQuery.devicePixelRatioOf(context))
        .ceil();

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Semantics(
              image: true,
              label: '$displayName profile avatar',
              child: CircleAvatar(
                key: const ValueKey('profile-avatar'),
                radius: 24,
                backgroundColor: AgrisellColors.fieldFill,
                backgroundImage: bytes == null
                    ? null
                    : ResizeImage(
                        MemoryImage(bytes),
                        width: decodedAvatarSize,
                        height: decodedAvatarSize,
                      ),
                child: bytes == null
                    ? const HomeAssetIcon(
                        asset: AgrisellAssets.iconMeActive,
                        size: 28,
                        color: AgrisellColors.authGreen,
                      )
                    : null,
              ),
            ),
          ),
          if (showEditBadge)
            Positioned(
              right: 1,
              bottom: 1,
              child: Semantics(
                button: true,
                label: 'Upload profile image',
                child: InkResponse(
                  onTap: onEdit,
                  radius: 17,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: ProfileAvatarStyles.containerDecoration,
                    child: const Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: AgrisellColors.surface,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
