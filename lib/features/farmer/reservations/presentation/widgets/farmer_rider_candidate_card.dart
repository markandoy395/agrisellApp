import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/shared/widgets/profile/safe_circle_avatar.dart';

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
    final distanceLabel = _pickupDistanceLabel(rider.distanceKm);
    return Semantics(
      container: true,
      label:
          '${rider.name}, ${rider.availabilityStatus} rider from '
          '${rider.barangay}, $distanceLabel',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AgrisellColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AgrisellColors.borderLine),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RiderAvatar(rider: rider),
                  const SizedBox(width: 10),
                  Expanded(child: _identity()),
                  _AvailabilityBadge(status: rider.availabilityStatus),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _Metric(
                    icon: Icons.star_rounded,
                    label: rider.rating == 0
                        ? 'No rating yet'
                        : rider.rating.toStringAsFixed(1),
                  ),
                  _Metric(
                    icon: Icons.local_shipping_outlined,
                    label: '${rider.completedDeliveries} completed',
                  ),
                  _Metric(icon: Icons.near_me_outlined, label: distanceLabel),
                  if (rider.estimatedArrivalMinutes != null)
                    _Metric(
                      icon: Icons.schedule_rounded,
                      label: '~${rider.estimatedArrivalMinutes} min',
                    ),
                  _Metric(
                    icon: rider.destinationSupported
                        ? Icons.verified_outlined
                        : Icons.block_outlined,
                    label: rider.destinationSupported
                        ? 'Within 15 km service area'
                        : 'Outside 15 km service area',
                  ),
                  if (farmerToBuyerDistanceKm != null)
                    _Metric(
                      icon: Icons.alt_route_outlined,
                      label:
                          'Farmer to buyer: '
                          '${farmerToBuyerDistanceKm!.toStringAsFixed(1)} km',
                    ),
                  if (rider.activeDeliveryCount > 0)
                    _Metric(
                      icon: Icons.work_outline_rounded,
                      label: '${rider.activeDeliveryCount} active',
                    ),
                  _Metric(
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
                height: 38,
                child: FilledButton(
                  onPressed: rider.canReceiveRequest ? onSelect : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AgrisellColors.authGreen,
                    foregroundColor: AgrisellColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox.square(
                          dimension: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AgrisellColors.surface,
                          ),
                        )
                      : Text(
                          rider.canReceiveRequest
                              ? rider.isOfflineManualCandidate
                                    ? 'Book offline rider'
                                    : 'Select rider'
                              : rider.availabilityStatus == 'online'
                              ? 'Rider is not eligible'
                              : 'Rider is ${_availabilityLabel(rider.availabilityStatus)}',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _identity() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        rider.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AgrisellColors.headingGreen,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        '${rider.barangay}, ${rider.municipality}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AgrisellColors.mutedText,
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w600,
        ),
      ),
      if (rider.sameBarangay)
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Same pickup barangay',
            style: TextStyle(
              color: AgrisellColors.authGreen,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        )
      else if (rider.sameMunicipality)
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Suggested: same municipality',
            style: TextStyle(
              color: AgrisellColors.authGreen,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      if (!rider.locationIsFresh && rider.distanceKm == null)
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Current GPS not available',
            style: TextStyle(
              color: AgrisellColors.statusOrangeText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
    ],
  );

  String _pickupDistanceLabel(double? distanceKm) {
    if (distanceKm == null) return 'Distance unavailable';
    final distance = '${distanceKm.toStringAsFixed(1)} km from pickup';
    return distance;
  }
}

class _RiderAvatar extends StatelessWidget {
  const _RiderAvatar({required this.rider});
  final FarmerRiderCandidate rider;

  @override
  Widget build(BuildContext context) {
    final initials = rider.name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return SafeCircleAvatar(
      radius: 24,
      backgroundColor: AgrisellColors.forestSoft,
      imageUrl: rider.profileImageUrl,
      fallback: Text(
        initials.isEmpty ? 'R' : initials,
        style: const TextStyle(
          color: AgrisellColors.authGreen,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final online = status == 'online';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: online
            ? AgrisellColors.statusGreenBackground
            : AgrisellColors.statusOrangeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _availabilityLabel(status),
        style: TextStyle(
          color: online
              ? AgrisellColors.statusGreenText
              : AgrisellColors.statusOrangeText,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _availabilityLabel(String status) => switch (status) {
  'busy' => 'Busy',
  'online' => 'Online',
  _ => 'Offline',
};

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Icon(icon, size: 15, color: AgrisellColors.authGreen),
      ),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          label,
          softWrap: true,
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
