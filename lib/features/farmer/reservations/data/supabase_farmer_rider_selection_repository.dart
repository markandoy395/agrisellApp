import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/farmer/reservations/data/farmer_rider_selection_mapper.dart';
import 'package:agresell_app/features/farmer/reservations/data/farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';

class SupabaseFarmerRiderSelectionRepository
    implements FarmerRiderSelectionRepository {
  SupabaseFarmerRiderSelectionRepository(this.client);

  final SupabaseClient client;
  static const _mapper = FarmerRiderSelectionMapper();

  @override
  Future<FarmerRiderSelectionData> loadEligibleRiders(String orderId) async {
    final response = await _guard(
      () => client.rpc<Object?>(
        'eligible_riders_for_current_farmer_order',
        params: {'p_seller_order_id': orderId},
      ),
    );
    final selection = _mapper.selection(response);
    final riders = await Future.wait(selection.riders.map(_withSignedPhoto));
    return FarmerRiderSelectionData(
      delivery: selection.delivery,
      riders: List.unmodifiable(riders),
    );
  }

  @override
  Future<List<FarmerRiderRequest>> loadCurrentRequests() async {
    final value = await _guard(
      () => client.rpc<Object?>('current_farmer_rider_assignment_requests'),
    );
    return _mapper.requests(value);
  }

  @override
  Stream<List<FarmerRiderRequest>> watchCurrentRequests() {
    late final StreamController<List<FarmerRiderRequest>> controller;
    RealtimeChannel? channel;
    var refreshing = false;
    var refreshAgain = false;

    Future<void> refresh() async {
      if (refreshing) {
        refreshAgain = true;
        return;
      }
      refreshing = true;
      do {
        refreshAgain = false;
        try {
          final values = await loadCurrentRequests();
          if (!controller.isClosed) controller.add(values);
        } catch (error, stackTrace) {
          if (!controller.isClosed) controller.addError(error, stackTrace);
        }
      } while (refreshAgain && !controller.isClosed);
      refreshing = false;
    }

    controller = StreamController<List<FarmerRiderRequest>>(
      onListen: () {
        channel = client
            .channel(
              'farmer-rider-requests:'
              '${DateTime.now().microsecondsSinceEpoch}',
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'rider_assignment_requests',
              callback: (_) => unawaited(refresh()),
            )
            .subscribe();
        unawaited(refresh());
      },
      onCancel: () async {
        final active = channel;
        if (active != null) await client.removeChannel(active);
      },
    );
    return controller.stream;
  }

  @override
  Future<FarmerRiderRequest> requestRider({
    required FarmerRiderDeliveryDetails delivery,
    required FarmerRiderCandidate rider,
  }) async {
    final params = <String, Object?>{
      'p_seller_order_id': delivery.orderId,
      'p_rider_id': rider.id,
      'p_requested_schedule': delivery.requestedSchedule
          .toUtc()
          .toIso8601String(),
      if (rider.proposedDeliveryFee != null)
        'p_proposed_delivery_fee': rider.proposedDeliveryFee,
    };
    final value = await _guard(
      () => client.rpc<Object?>('request_current_farmer_rider', params: params),
    );
    return _mapper.request(value);
  }

  @override
  Future<FarmerRiderRequest> cancelRequest(String requestId) async {
    final value = await _guard(
      () => client.rpc<Object?>(
        'cancel_current_farmer_rider_request',
        params: {'p_request_id': requestId},
      ),
    );
    return _mapper.request(value);
  }

  Future<FarmerRiderCandidate> _withSignedPhoto(
    FarmerRiderCandidate rider,
  ) async {
    final path = rider.profilePhotoPath;
    if (path == null) return rider;
    try {
      final url = await client.storage
          .from('rider-documents')
          .createSignedUrl(path, 3600);
      return rider.copyWith(profileImageUrl: url);
    } on Object {
      return rider;
    }
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on PostgrestException catch (error) {
      throw FarmerRiderSelectionException(_friendlyMessage(error));
    } on AuthException {
      throw const FarmerRiderSelectionException(
        'Sign in as the farmer for this order and try again.',
      );
    } on Object {
      throw const FarmerRiderSelectionException(
        'The rider service is unavailable. Please try again.',
      );
    }
  }

  String _friendlyMessage(PostgrestException error) {
    final message = error.message.trim();
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('rider_locations') ||
        lowerMessage.contains('public.rider_locations') ||
        lowerMessage.contains('relation') &&
            lowerMessage.contains('does not exist')) {
      return 'Rider live location data is not ready yet. Please apply the latest database migrations and try again.';
    }
    return message.isEmpty
        ? 'The rider service is unavailable. Please try again.'
        : message;
  }
}
