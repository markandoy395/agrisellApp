import 'dart:async';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_foundation_repositories.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_earning.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_transition_validator.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_acceptance_state.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_acceptance_validator.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_ordering.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_matcher.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_arrival_validation.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_problem.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_delivery.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_optimizer.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_bundle.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment_record.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_history.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_requirement.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_acceptance_failure_mapper.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_rider_evidence_uploader.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'package:agresell_app/features/rider/safety/data/supabase_rider_incident_store.dart';
import 'package:agresell_app/features/shared/orders/domain/rider_assignment_request_status.dart';

part 'in_memory_rider_acceptance.dart';
part 'in_memory_rider_delivery_repository.dart';
part 'in_memory_rider_delivery_requests.dart';
part 'in_memory_rider_delivery_status.dart';
part 'in_memory_rider_delivery_status_event.dart';
part 'in_memory_rider_delivery_completion.dart';
part 'in_memory_rider_delivery_completion_validation.dart';
part 'in_memory_rider_delivery_proof_validation.dart';
part 'in_memory_rider_delivery_inspection.dart';
part 'in_memory_rider_delivery_problems.dart';
part 'in_memory_rider_pickup_confirmation.dart';
part 'in_memory_rider_pickup_validation.dart';
part 'in_memory_rider_batch.dart';
part 'supabase_rider_delivery_repository.dart';
part 'supabase_rider_delivery_mapping.dart';
part 'supabase_rider_delivery_workflow.dart';
part 'supabase_rider_delivery_completion.dart';
part 'supabase_rider_delivery_finalization.dart';
part 'supabase_rider_delivery_records.dart';
part 'supabase_rider_delivery_incidents.dart';
part 'supabase_rider_delivery_evidence.dart';

/// Contract for the server-authoritative rider delivery API.
abstract interface class RiderDeliveryRepository
    implements DeliveryRequestRepository {
  @override
  Future<List<DeliveryRequest>> fetchRequests({
    required String riderId,
    RiderDeliverySearch? search,
  });

  /// Production implementations must authenticate [command.riderId], load
  /// current eligibility server-side, and commit all returned state atomically.
  Future<DeliveryAcceptanceReceipt> acceptDelivery(
    DeliveryAcceptanceCommand command,
  );

  Future<DeliveryRequest> decline({
    required String requestId,
    required String riderId,
  });

  Future<DeliveryRequest> cancel({
    required String requestId,
    required String riderId,
    required String reason,
  });

  Future<DeliveryRequest> advance({
    required String requestId,
    required String riderId,
    required DeliveryStage nextStage,
    DeliveryProof? proof,
  });

  /// Server-authoritative Phase 5 delivery-status workflow.
  Future<DeliveryStatusSnapshot> updateDeliveryStatus(
    DeliveryStatusUpdateCommand command,
  );

  /// Loads the server's active delivery during restart and refresh.
  Future<DeliveryStatusSnapshot?> fetchActiveDeliveryStatus(String riderId);

  Future<List<DeliveryStatusSnapshot>> fetchActiveDeliveryStatuses(
    String riderId,
  );

  Future<PickupConfiguration> fetchPickupConfiguration({
    required String deliveryId,
    required String riderId,
  });

  Future<PickupCompletionResult> completePickup(
    PickupCompletionCommand command,
  );

  Future<PickupProblemReport> reportPickupProblem(PickupProblemReport report);

  Future<DeliveryCompletionConfiguration> fetchDeliveryConfiguration({
    required String deliveryId,
    required String riderId,
  });

  /// Production implementations must validate proof and commit completion,
  /// history, notifications, and active-delivery cleanup atomically.
  Future<DeliveryCompletionResult> completeDelivery(
    DeliveryCompletionCommand command,
  );

  Future<List<DeliveryCompletionRecord>> fetchCompletedDeliveries(
    String riderId,
  );

  Future<DeliveryDestinationProblemReport> reportDestinationProblem(
    DeliveryDestinationProblemReport report,
  );

  Future<RiderDeliveryProblemReport> reportDeliveryProblem(
    RiderDeliveryProblemReport report,
  );

  Future<RiderDeliveryProblemReport?> updateDeliveryProblemStatus({
    required String riderId,
    required String reportId,
    required RiderDeliveryProblemStatus status,
  });

  /// Production implementations apply this query server-side. Values in the
  /// query are presentation hints and must not authorize acceptance.
  Future<RiderRequestPage> fetchNearbyRequests(RiderRequestQuery query);

  /// Private-safe invalidations only; consumers re-run their paged query.
  Stream<void> watchRequestChanges({required String riderId});
}
