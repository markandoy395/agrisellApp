import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_candidate_card_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_availability_badge.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_avatar.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_identity_section.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_metric_item.dart';

class FarmerRiderCandidateCard extends StatelessWidget {
  const FarmerRiderCandidateCard({
    required this.rider,
    required this.onSelect,
    required this.isSubmitting,
    this.farmerToBuyerDistanceKm,
    super.key,
  });

  final FarmerRiderCandidate rider;
  final VoidCallback? onSelect;
  final bool isSubmitting;
  final double? farmerToBuyerDistanceKm;

  @override
  Widget build(BuildContext context) {
    final distanceLabel =
        FarmerRiderCandidateCardStyles.pickupDistanceLabel(rider.distanceKm);

    return Semantics(
      container: true,
      label:
          '${rider.name}, ${rider.availabilityStatus} rider from '
          '${rider.barangay}, $distanceLabel',
      child: DecoratedBox(
        decoration: FarmerRiderCandidateCardStyles.cardDecoration,
        child: Padding(
          padding: FarmerRiderCandidateCardStyles.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FarmerRiderAvatar(rider: rider),
                  const SizedBox(width: 10),
                  Expanded(child: FarmerRiderIdentitySection(rider: rider)),
                  FarmerRiderAvailabilityBadge(
                    status: rider.availabilityStatus,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: FarmerRiderCandidateCardStyles.metricsWrapSpacing,
                runSpacing:
                    FarmerRiderCandidateCardStyles.metricsWrapRunSpacing,
                children: [
                  FarmerRiderMetricItem(
                    icon: Icons.star_rounded,
                    label: rider.rating == 0
                        ? 'No rating yet'
                        : rider.rating.toStringAsFixed(1),
                  ),
                  FarmerRiderMetricItem(
                    icon: Icons.local_shipping_outlined,
                    label: '${rider.completedDeliveries} completed',
                  ),
                  FarmerRiderMetricItem(
                    icon: Icons.near_me_outlined,
                    label: distanceLabel,
                  ),
                  if (rider.estimatedArrivalMinutes != null)
                    FarmerRiderMetricItem(
                      icon: Icons.schedule_rounded,
                      label: '~${rider.estimatedArrivalMinutes} min',
                    ),
                  FarmerRiderMetricItem(
                    icon: rider.destinationSupported
                        ? Icons.verified_outlined
                        : Icons.block_outlined,
                    label: rider.destinationSupported
                        ? 'Within 15 km service area'
                        : 'Outside 15 km service area',
                  ),
                  if (farmerToBuyerDistanceKm != null)
                    FarmerRiderMetricItem(
                      icon: Icons.alt_route_outlined,
                      label:
                          'Farmer to buyer: '
                          '${farmerToBuyerDistanceKm!.toStringAsFixed(1)} km',
                    ),
                  if (rider.activeDeliveryCount > 0)
                    FarmerRiderMetricItem(
                      icon: Icons.work_outline_rounded,
                      label: '${rider.activeDeliveryCount} active',
                    ),
                  FarmerRiderMetricItem(
                    icon: Icons.payments_outlined,
                    label: rider.proposedDeliveryFee == null
                        ? 'Fee pending'
                        : 'PHP ${rider.proposedDeliveryFee!.toStringAsFixed(2)}',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: FarmerRiderCandidateCardStyles.buttonHeight,
                child: FilledButton(
                  onPressed: rider.canReceiveRequest ? onSelect : null,
                  style: FarmerRiderCandidateCardStyles.buttonStyle,
                  child: isSubmitting
                      ? const SizedBox.square(
                          dimension: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AgrisellColors.surface,
                          ),
                        )
                      : Text(
                          FarmerRiderCandidateCardStyles.actionButtonLabel(
                            rider,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
