import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/shared/widgets/profile/safe_circle_avatar.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_follow_stats.dart';
import '../styles/rider_profile_design_styles.dart';
import 'rider_profile_design_components.dart';

class RiderProfileIdentityCard extends StatelessWidget {
  const RiderProfileIdentityCard({required this.profile, super.key});
  final RiderProfile profile;
  @override
  Widget build(BuildContext context) {
    final verified =
        profile.verificationStatus == RiderVerificationStatus.verified;
    return RiderProfileCard(
      child: Row(
        children: [
          SafeCircleAvatar(
            radius: 48,
            imageUrl: profile.profilePhotoUrl,
            backgroundColor: AgrisellColors.forestSoft,
            fallback: const Icon(
              Icons.person_outline_rounded,
              size: 45,
              color: AgrisellColors.authGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.fullName, style: RiderProfileDesignStyles.heading),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: RiderProfileDesignStyles.badge(
                    verified
                        ? AgrisellColors.authGreen
                        : AgrisellColors.statusOrangeText,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        verified
                            ? Icons.verified_rounded
                            : Icons.pending_outlined,
                        size: 17,
                        color: verified
                            ? AgrisellColors.authGreen
                            : AgrisellColors.statusOrangeText,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          verified
                              ? 'Verified Rider'
                              : profile.verificationStatus.label,
                          style: RiderProfileDesignStyles.body,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const ProfileFollowStats(
                  foregroundColor: AgrisellColors.headingGreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
