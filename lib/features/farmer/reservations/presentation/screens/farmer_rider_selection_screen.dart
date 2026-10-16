import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/reservations/data/farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_candidate_card.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_confirmation_dialog.dart';
import '../widgets/farmer_delivery_fee_dialog.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_selection_states.dart';

class FarmerRiderSelectionScreen extends StatefulWidget {
  const FarmerRiderSelectionScreen({
    required this.orderId,
    required this.repository,
    super.key,
  });

  final String orderId;
  final FarmerRiderSelectionRepository repository;

  @override
  State<FarmerRiderSelectionScreen> createState() =>
      _FarmerRiderSelectionScreenState();
}

class _FarmerRiderSelectionScreenState
    extends State<FarmerRiderSelectionScreen> {
  FarmerRiderSelectionData? _selection;
  Object? _error;
  String? _submittingRiderId;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _selection = null;
      _error = null;
    });
    try {
      final result = await widget.repository.loadEligibleRiders(widget.orderId);
      if (!mounted) return;
      setState(() => _selection = result);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    appBar: AppBar(
      backgroundColor: AgrisellColors.authGreen,
      foregroundColor: AgrisellColors.surface,
      title: const Text(
        'Choose a rider',
        style: SharedPresentationStyles.titleExtraBold,
      ),
    ),
    body: SafeArea(child: _content()),
  );

  Widget _content() {
    if (_error != null) {
      return FarmerRiderSelectionStateView(
        icon: Icons.cloud_off_outlined,
        title: 'Riders could not be loaded',
        message: _message(_error!),
        actionLabel: 'Try again',
        onAction: _load,
      );
    }
    final selection = _selection;
    if (selection == null) {
      return const FarmerRiderSelectionStateView(
        icon: Icons.sync_rounded,
        title: 'Loading eligible riders',
        message:
            'Checking availability, pickup, buyer destination, and delivery conflicts.',
        isLoading: true,
      );
    }
    final eligibleRiders = eligibleRidersNearestFirst(selection.riders);
    if (eligibleRiders.isEmpty) {
      return FarmerRiderSelectionStateView(
        icon: Icons.delivery_dining_outlined,
        title: 'No eligible riders available',
        message:
            'No active rider is currently online and able to accept this '
            'delivery. Try again shortly.',
        actionLabel: 'Refresh',
        onAction: _load,
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AgrisellColors.authGreen,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        itemCount: eligibleRiders.length + 2,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FarmerRiderDeliverySummary(selection: selection);
          }
          if (index == 1) {
            return const FarmerRiderGroupNotice(
              icon: Icons.near_me_outlined,
              message:
                  'All eligible riders are shown nearest to farthest from '
                  'the pickup location. The rider must still accept before '
                  'assignment.',
            );
          }
          final rider = eligibleRiders[index - 2];
          return FarmerRiderCandidateCard(
            rider: rider,
            farmerToBuyerDistanceKm:
                rider.deliveryDistanceKm ?? selection.delivery.routeDistanceKm,
            isSubmitting: _submittingRiderId == rider.id,
            onSelect: _submittingRiderId == null && rider.canReceiveRequest
                ? () => _select(selection, rider)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _select(
    FarmerRiderSelectionData selection,
    FarmerRiderCandidate rider,
  ) async {
    final fee = await showFarmerDeliveryFeeDialog(
      context,
      initialFee: rider.proposedDeliveryFee,
    );
    if (fee == null || !mounted) return;
    rider = rider.copyWith(proposedDeliveryFee: fee);
    final confirmed = await showFarmerRiderConfirmationDialog(
      context,
      rider: rider,
      delivery: selection.delivery,
    );
    if (!confirmed || !mounted) return;
    setState(() => _submittingRiderId = rider.id);
    try {
      final request = await widget.repository.requestRider(
        delivery: selection.delivery,
        rider: rider,
      );
      if (!mounted) return;
      Navigator.of(context).pop<FarmerRiderRequest>(request);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _submittingRiderId = null);
      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(SnackBar(content: Text(_message(error))));
    }
  }

  String _message(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '').trim();
    return text.isEmpty ? 'Please try again.' : text;
  }
}
