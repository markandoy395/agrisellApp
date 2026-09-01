import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_actions.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_components.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_logistics_company_card.dart';
import 'package:agresell_app/features/rider/presentation/rider_availability_presentation.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_status_pills.dart';
import 'package:agresell_app/features/shared/widgets/profile/safe_circle_avatar.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_follow_stats.dart';

class RiderProfileOverview extends StatelessWidget {
  const RiderProfileOverview({
    required this.profile,
    required this.onEarnings,
    required this.onHistory,
    required this.onRatings,
    this.performance,
    super.key,
  });

  final RiderProfile profile;
  final VoidCallback onEarnings;
  final VoidCallback onHistory;
  final VoidCallback onRatings;
  final RiderRatingsSummary? performance;

  @override
  Widget build(BuildContext context) {
    final status = profile.verificationStatus;
    final isVerified = status == RiderVerificationStatus.verified;
    final isRejected =
        status == RiderVerificationStatus.rejected ||
        status == RiderVerificationStatus.suspended;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 156),
      children: [
        RiderSurfaceCard(
          child: Row(
            children: [
              SafeCircleAvatar(
                radius: 32,
                imageUrl: profile.profilePhotoUrl,
                fallback: const Icon(Icons.person_rounded, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        color: AgrisellColors.headingGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const ProfileFollowStats(
                      foregroundColor: AgrisellColors.headingGreen,
                    ),
                    const SizedBox(height: 5),
                    RiderVerificationPill(
                      label: status.label,
                      backgroundColor: isVerified
                          ? AgrisellColors.statusGreenBackground
                          : isRejected
                          ? AgrisellColors.statusRedBackground
                          : AgrisellColors.statusOrangeBackground,
                      foregroundColor: isVerified
                          ? AgrisellColors.statusGreenText
                          : isRejected
                          ? AgrisellColors.statusRedText
                          : AgrisellColors.statusOrangeText,
                      icon: isVerified
                          ? Icons.verified_rounded
                          : Icons.pending_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const RiderSectionTitle(title: 'Delivery performance'),
        const SizedBox(height: 8),
        RiderProfileMetricsCard(summary: performance),
        const SizedBox(height: 14),
        RiderProfileInformationCard(
          title: 'Rider information',
          rows: [
            RiderProfileInfoRow(Icons.phone_outlined, profile.contactNumber),
            RiderProfileInfoRow(Icons.email_outlined, profile.email),
            RiderProfileInfoRow(Icons.home_outlined, profile.addressLabel),
          ],
        ),
        const SizedBox(height: 12),
        RiderLogisticsCompanyCard(companyId: profile.logisticCompanyId),
        const SizedBox(height: 12),
        RiderProfileInformationCard(
          title: 'Vehicle credentials',
          rows: [
            RiderProfileInfoRow(
              Icons.two_wheeler_outlined,
              profile.vehicleType.label,
            ),
            RiderProfileInfoRow(Icons.badge_outlined, profile.licenseNumber),
            RiderProfileInfoRow(
              Icons.confirmation_number_outlined,
              profile.vehiclePlateNumber,
            ),
          ],
        ),
        const SizedBox(height: 12),
        RiderProfileInformationCard(
          title: 'Rider status',
          rows: [
            RiderProfileInfoRow(
              Icons.location_on_outlined,
              profile.hasRegisteredServiceCoordinates
                  ? 'Exact GPS location captured'
                  : 'GPS location unavailable',
            ),
            RiderProfileInfoRow(
              Icons.toggle_on_outlined,
              profile.availabilityStatus.displayLabel,
            ),
            RiderProfileInfoRow(
              Icons.work_outline_rounded,
              profile.employmentStatus.label,
            ),
            RiderProfileInfoRow(
              Icons.star_outline_rounded,
              profile.rating.toStringAsFixed(1),
            ),
            RiderProfileInfoRow(
              Icons.delivery_dining_outlined,
              '${profile.totalDeliveries} total deliveries',
            ),
          ],
        ),
        const SizedBox(height: 12),
        RiderProfileActions(
          onEarnings: onEarnings,
          onHistory: onHistory,
          onRatings: onRatings,
        ),
      ],
    );
  }
}
