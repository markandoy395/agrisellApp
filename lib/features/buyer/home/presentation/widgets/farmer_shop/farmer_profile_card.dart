import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_avatar.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_follow_button.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_rating_line.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_text_styles.dart';

class FarmerProfileCard extends StatelessWidget {
  const FarmerProfileCard({
    required this.farmer,
    required this.height,
    required this.onChat,
    this.followController,
    super.key,
  });

  final FarmerProfile farmer;
  final double height;
  final VoidCallback onChat;
  final FarmerFollowController? followController;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final avatarSize = width < 380 ? 44.0 : 48.0;
    final actionWidth = width < 380 ? 86.0 : 92.0;

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AgrisellColors.authGreen,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: AgrisellColors.brandBlack.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 6, 11, 6),
          child: Row(
            children: [
              FarmerAvatar(farmer: farmer, size: avatarSize),
              const SizedBox(width: 8),
              Expanded(child: _FarmerProfileText(farmer: farmer)),
              const SizedBox(width: 6),
              _ProfileActions(
                farmer: farmer,
                width: actionWidth,
                onChat: onChat,
                followController: followController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FarmerProfileText extends StatelessWidget {
  const _FarmerProfileText({required this.farmer});

  final FarmerProfile farmer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          farmer.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FarmerTextStyles.sellerName(context),
        ),
        const SizedBox(height: 2),
        Text(
          farmer.location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: FarmerTextStyles.sellerLocation(context),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            FarmerRatingLine(rating: farmer.rating, starSize: 13),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${farmer.followerCount} followers',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AgrisellColors.surface.withValues(alpha: 0.88),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileActions extends StatelessWidget {
  const _ProfileActions({
    required this.farmer,
    required this.width,
    required this.onChat,
    this.followController,
  });

  final FarmerProfile farmer;
  final double width;
  final VoidCallback onChat;
  final FarmerFollowController? followController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: width,
          child: FarmerFollowButton(
            farmer: farmer,
            controller: followController,
            compact: true,
            onDarkBackground: true,
          ),
        ),
        const SizedBox(height: 4),
        _ProfileActionButton(
          width: width,
          icon: Icons.chat_bubble_rounded,
          label: 'Chat',
          onTap: onChat,
        ),
      ],
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.width,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 30,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: AgrisellColors.surface,
          side: const BorderSide(color: AgrisellColors.surface, width: 1.4),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 7),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
