import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'package:agresell_app/features/rider/presentation/rider_availability_presentation.dart';
import '../styles/rider_profile_design_styles.dart';
import 'rider_profile_design_components.dart';
import 'rider_profile_identity_card.dart';
import 'rider_profile_performance_card.dart';
import 'rider_profile_actions.dart';
import 'rider_logistics_company_card.dart';
import 'rider_profile_documents_section.dart';

class RiderProfileOverview extends StatelessWidget {
  const RiderProfileOverview({
    required this.profile,
    required this.onEarnings,
    required this.onHistory,
    required this.onRatings,
    this.onEdit,
    this.onVehicle,
    this.onDocuments,
    this.performance,
    super.key,
  });
  final RiderProfile profile;
  final VoidCallback onEarnings;
  final VoidCallback onHistory;
  final VoidCallback onRatings;
  final VoidCallback? onEdit;
  final VoidCallback? onVehicle;
  final VoidCallback? onDocuments;
  final RiderRatingsSummary? performance;

  @override
  Widget build(BuildContext context) => ListView(
    key: const PageStorageKey('rider-profile-overview'),
    padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
    children: [
      RiderProfileIdentityCard(profile: profile),
      const SizedBox(height: 14),
      RiderProfilePerformanceCard(summary: performance),
      const SizedBox(height: 18),
      Text('Rider status', style: RiderProfileDesignStyles.title),
      const SizedBox(height: 10),
      RiderProfileCard(
        child: Column(
          children: [
            RiderProfileDetailRow(
              icon: Icons.circle,
              iconColor: profile.availabilityStatus == RiderAvailability.offline
                  ? AgrisellColors.mutedText
                  : AgrisellColors.authGreen,
              label: profile.availabilityStatus.displayLabel,
              value: 'Work availability',
            ),
            RiderProfileDetailRow(
              icon: Icons.work_outline_rounded,
              label: profile.employmentStatus.label,
              value: 'Employment status',
            ),
            RiderProfileDetailRow(
              icon: Icons.star_outline_rounded,
              label: '${profile.rating.toStringAsFixed(1)} rating',
              value: '${profile.totalDeliveries} total deliveries',
            ),
            RiderProfileDetailRow(
              icon: Icons.location_on_outlined,
              label: 'Registered service location',
              value: profile.hasRegisteredServiceCoordinates
                  ? 'Exact GPS location captured'
                  : 'GPS location unavailable',
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Text('Activity', style: RiderProfileDesignStyles.title),
      const SizedBox(height: 10),
      RiderProfileActions(
        onEarnings: onEarnings,
        onHistory: onHistory,
        onRatings: onRatings,
      ),
      const SizedBox(height: 18),
      RiderProfileSection(
        title: 'Rider information',
        icon: Icons.assignment_ind_outlined,
        action: onEdit == null
            ? null
            : TextButton(onPressed: onEdit, child: const Text('Edit')),
        children: [
          RiderProfileDetailRow(
            icon: Icons.phone_outlined,
            label: 'Contact number',
            value: profile.contactNumber,
          ),
          RiderProfileDetailRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: profile.email,
          ),
          RiderProfileDetailRow(
            icon: Icons.home_outlined,
            label: 'Address',
            value: profile.addressLabel,
          ),
        ],
      ),
      const SizedBox(height: 12),
      RiderLogisticsCompanyCard(companyId: profile.logisticCompanyId),
      const SizedBox(height: 12),
      RiderProfileSection(
        title: 'Vehicle credentials',
        icon: Icons.two_wheeler_outlined,
        action: onVehicle == null
            ? null
            : TextButton(onPressed: onVehicle, child: const Text('Edit')),
        children: [
          RiderProfileDetailRow(
            icon: Icons.two_wheeler_outlined,
            label: 'Type',
            value: profile.vehicleType.label,
          ),
          RiderProfileDetailRow(
            icon: Icons.confirmation_number_outlined,
            label: 'Plate number',
            value: profile.vehiclePlateNumber,
          ),
          RiderProfileDetailRow(
            icon: Icons.badge_outlined,
            label: 'License number',
            value: profile.licenseNumber,
          ),
        ],
      ),
      const SizedBox(height: 12),
      RiderProfileDocumentsSection(onViewAll: onDocuments),
    ],
  );
}
