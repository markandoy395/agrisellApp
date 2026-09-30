import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/presentation/rider_availability_presentation.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/shared/widgets/profile/safe_circle_avatar.dart';

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
    final firstName = profile?.firstName.trim();
    final statusLabel = _compactStatusLabel(workStatus);
    final subtitle = profile == null
        ? 'Current work status: ${workStatus.displayLabel}'
        : '${profile!.vehicleType.label} ${_plateLabel(profile!.vehiclePlateNumber)}';
    return RiderPageHeader(
      title: firstName == null || firstName.isEmpty
          ? 'Hello, Rider'
          : 'Hello, $firstName',
      subtitle: subtitle,
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AgrisellColors.surface.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AgrisellColors.surface.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(workStatus.icon, color: AgrisellColors.surface, size: 15),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 76),
                  child: Text(
                    statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AgrisellColors.surface,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: unreadNotifications == 0
                    ? 'Notifications'
                    : '$unreadNotifications unread notifications',
                onPressed: onOpenNotifications,
                style: IconButton.styleFrom(
                  foregroundColor: AgrisellColors.surface,
                  backgroundColor: AgrisellColors.surface.withValues(
                    alpha: 0.14,
                  ),
                ),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              if (unreadNotifications > 0)
                Positioned(
                  right: 3,
                  top: 3,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AgrisellColors.accentOrange,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AgrisellColors.authGreen),
                    ),
                    child: Text(
                      unreadNotifications > 9 ? '9+' : '$unreadNotifications',
                      style: const TextStyle(
                        color: AgrisellColors.brandBlack,
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          SafeCircleAvatar(
            radius: 19,
            backgroundColor: AgrisellColors.surface.withValues(alpha: 0.2),
            imageUrl: profile?.profilePhotoUrl,
            fallback: const Icon(
              Icons.person_rounded,
              color: AgrisellColors.surface,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

String _plateLabel(String value) {
  final plate = value.trim();
  return plate.isEmpty ? '' : ' - $plate';
}

String _compactStatusLabel(RiderAvailability status) => switch (status) {
  RiderAvailability.onlineAvailable => 'Online',
  RiderAvailability.reviewingDeliveryRequest => 'Reviewing',
  RiderAvailability.deliveryReserved => 'Reserved',
  RiderAvailability.goingToPickup => 'Pickup',
  RiderAvailability.waitingAtPickup => 'At Pickup',
  RiderAvailability.productPickedUp => 'Picked Up',
  RiderAvailability.goingToBuyer => 'Delivery',
  RiderAvailability.waitingAtDeliveryLocation => 'At Drop-off',
  RiderAvailability.temporarilyUnavailable => 'Unavailable',
  _ => status.displayLabel,
};
