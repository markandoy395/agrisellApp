import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';

abstract final class SupabaseDeliveryAcceptanceFailureMapper {
  static DeliveryAcceptanceFailure map(DeliveryDataException error) {
    final message = error.message.toLowerCase();
    if (message.contains('active_delivery_limit_reached')) {
      return DeliveryAcceptanceFailure.activeDeliveryLimit;
    }
    if (message.contains('delivery_request_expired') ||
        message.contains('delivery request expired') ||
        message.contains('deadline_conflict')) {
      return DeliveryAcceptanceFailure.expired;
    }
    if (message.contains('delivery_request_missing') ||
        message.contains('delivery not found')) {
      return DeliveryAcceptanceFailure.requestNotFound;
    }
    if (message.contains('capacity_conflict')) {
      return DeliveryAcceptanceFailure.capacityMismatch;
    }
    if (message.contains('vehicle_type_conflict')) {
      return DeliveryAcceptanceFailure.vehicleMismatch;
    }
    if (message.contains('route_incompatible') ||
        message.contains('product_handling_conflict')) {
      return DeliveryAcceptanceFailure.batchIncompatible;
    }
    if (message.contains('cod_responsibility_unavailable')) {
      return DeliveryAcceptanceFailure.codUnavailable;
    }
    return switch (error.type) {
      DeliveryDataFailureType.conflict =>
        DeliveryAcceptanceFailure.alreadyAssigned,
      DeliveryDataFailureType.timeout =>
        DeliveryAcceptanceFailure.networkTimeout,
      DeliveryDataFailureType.offline =>
        DeliveryAcceptanceFailure.networkTimeout,
      DeliveryDataFailureType.authentication ||
      DeliveryDataFailureType.authorization =>
        DeliveryAcceptanceFailure.riderNotAllowed,
      DeliveryDataFailureType.validation =>
        DeliveryAcceptanceFailure.riderIneligible,
      _ => DeliveryAcceptanceFailure.serverError,
    };
  }
}
