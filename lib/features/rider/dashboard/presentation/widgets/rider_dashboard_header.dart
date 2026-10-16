import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:flutter/material.dart';
import '../../../profile/domain/rider_profile.dart';
import '../../../presentation/rider_availability_presentation.dart';
import '../../../../shared/widgets/profile/safe_circle_avatar.dart';
import '../styles/rider_home_design_styles.dart';

class RiderDashboardHeader extends StatelessWidget {
  const RiderDashboardHeader({
    required this.profile,
    required this.workStatus,
    required this.unreadNotifications,
    required this.onOpenNotifications,
    super.key,
  });
  final RiderProfile? profile;
  final RiderAvailability workStatus;
  final int unreadNotifications;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final name = profile?.firstName.trim();
    final vehicle = profile?.vehicleType.label ?? 'Your delivery partner';
    final plate = profile?.vehiclePlateNumber.trim() ?? '';
    return Container(
      decoration: RiderHomeDesignStyles.headerBackground,
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.paddingOf(context).top + 18,
        18,
        18,
      ),
      child: Row(
        children: [
          SafeCircleAvatar(
            radius: 28,
            imageUrl: profile?.profilePhotoUrl,
            backgroundColor: AgrisellColors.surface,
            fallback: const Icon(
              Icons.person_rounded,
              color: RiderHomeDesignStyles.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${name == null || name.isEmpty ? 'Rider' : name}',
                  style: RiderHomeDesignStyles.greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.two_wheeler_rounded,
                      color: AgrisellColors.surface,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$vehicle${plate.isEmpty ? '' : ' • $plate'}',
                        style: RiderHomeDesignStyles.whiteCaption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: RiderHomeDesignStyles.status(workStatus.isOnline),
                  child: Text(
                    workStatus.isOnline ? 'Online' : workStatus.displayLabel,
                    style: RiderHomeDesignStyles.statusText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: '$unreadNotifications unread notifications',
            child: InkWell(
              onTap: onOpenNotifications,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_rounded,
                          color: AgrisellColors.accentBlue,
                          size: 30,
                        ),
                        if (unreadNotifications > 0)
                          Positioned(
                            right: -5,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: RiderHomeDesignStyles.badge,
                              child: Text(
                                unreadNotifications > 99
                                    ? '99+'
                                    : '$unreadNotifications',
                                style: RiderHomeDesignStyles.badgeText,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Notifications',
                      style: RiderHomeDesignStyles.whiteCaption,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
