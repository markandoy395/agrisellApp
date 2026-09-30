import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';

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
      // ── Top bar: back + title + cart + settings ─────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
        child: Row(
          children: [
            if (onBack != null) ...[
              _NavButton(
                tooltip: 'Back',
                onPressed: onBack!,
                icon: Icons.arrow_back_ios_new_rounded,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: BuyerProfileStyle.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            if (onBasketTap != null) ...[
              _BasketNavButton(onPressed: onBasketTap!),
            ],
            if (showSettingsIcon && onSettingsTap != null) ...[
              const SizedBox(width: 8),
              _NavButton(
                tooltip: 'Settings',
                onPressed: onSettingsTap!,
                icon: Icons.tune_rounded,
              ),
            ],
          ],
        ),
      ),

      // ── Hero banner ──────────────────────────────────────────────────────
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: const BoxDecoration(
            gradient: BuyerProfileStyle.heroGradient,
          ),
          child: Stack(
            children: [
              // Decorative background pattern
              Positioned.fill(child: CustomPaint(painter: _HeroPatternPainter())),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    _BuyerHeroAvatar(
                      name: profile.headerName,
                      isVerified: isVerified,
                      showEditBadge: showAvatarEditBadge,
                      imageBytes: avatarImageBytes,
                      onEdit: onAvatarEdit,
                    ),
                    const SizedBox(width: 14),
                    // Name + stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.headerName,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          BuyerGlassChip(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isVerified
                                        ? Icons.verified_rounded
                                        : Icons.shopping_bag_outlined,
                                    color: const Color(0xFF6FFAB3),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isVerified ? 'Verified Buyer' : 'Buyer Account',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _StatPill(
                                      value: followingCount,
                                      label: 'Following',
                                    ),
                                    _StatPill(
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

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: BuyerProfileStyle.mint,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: BuyerProfileStyle.borderSubtle, width: 1),
        ),
        child: Icon(icon, color: BuyerProfileStyle.green, size: 20),
      ),
    ),
  );
}

class _BasketNavButton extends StatelessWidget {
  const _BasketNavButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Cart',
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: BuyerProfileStyle.mint,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: BuyerProfileStyle.borderSubtle, width: 1),
        ),
        child: const Icon(
          Icons.shopping_cart_outlined,
          color: BuyerProfileStyle.green,
          size: 20,
        ),
      ),
    ),
  );
}

class _BuyerHeroAvatar extends StatelessWidget {
  const _BuyerHeroAvatar({
    required this.name,
    required this.isVerified,
    this.showEditBadge = false,
    this.imageBytes,
    this.onEdit,
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
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E6B43).withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: _avatarImage(),
          ),
        ),
        if (showEditBadge || onEdit != null)
          Positioned(
            right: -2,
            bottom: 2,
            child: Semantics(
              button: true,
              label: 'Change avatar',
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1BB871), Color(0xFF08683F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          )
        else if (isVerified)
          Positioned(
            right: -2,
            bottom: 2,
            child: Semantics(
              label: 'Verified',
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1BB871), Color(0xFF08683F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 15,
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
        width: 88,
        height: 88,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF1A7A52), Color(0xFF0E5C38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Color(0xFFB8F0D6),
        size: 52,
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => BuyerGlassChip(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$value ',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: label,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Background decoration painter ────────────────────────────────────────────

class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.04);

    // Large blurred circle — top-right
    canvas.drawCircle(
      Offset(size.width + 10, -20),
      110,
      paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
    );

    // Leaf shape — bottom-left
    final leaf = Paint()..color = Colors.white.withValues(alpha: 0.055);
    final path1 = Path()
      ..moveTo(-20, size.height + 10)
      ..quadraticBezierTo(30, size.height - 60, 90, size.height - 20)
      ..quadraticBezierTo(50, size.height + 30, -20, size.height + 10)
      ..close();
    canvas.drawPath(path1, leaf);

    // Leaf shape — bottom-right
    final path2 = Path()
      ..moveTo(size.width - 60, size.height + 8)
      ..quadraticBezierTo(
        size.width - 20,
        size.height - 50,
        size.width + 20,
        size.height - 30,
      )
      ..quadraticBezierTo(
        size.width + 10,
        size.height + 20,
        size.width - 60,
        size.height + 8,
      )
      ..close();
    canvas.drawPath(path2, leaf);
  }

  @override
  bool shouldRepaint(covariant _HeroPatternPainter oldDelegate) => false;
}
