import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/delivery.dart';
import '../domain/delivery_bundle.dart';
import '../domain/delivery_location.dart';
import '../domain/delivery_payment_record.dart';
import '../domain/delivery_payment.dart';
import '../domain/delivery_proof.dart';
import '../domain/delivery_requirement.dart';
import '../domain/delivery_status.dart';
import '../domain/delivery_status_history.dart';
import '../domain/delivery_status_update.dart';

part 'supabase_delivery_mutations.dart';
part 'supabase_delivery_proofs.dart';

enum DeliveryDataFailureType {
  authentication,
  authorization,
  validation,
  conflict,
  offline,
  timeout,
  storage,
  database,
}

class DeliveryDataException implements Exception {
  const DeliveryDataException(this.type, this.message, [this.cause]);
  final DeliveryDataFailureType type;
  final String message;
  final Object? cause;
  @override
  String toString() => message;
}

class SupabaseDeliveryDataSource {
  const SupabaseDeliveryDataSource(this.client);

  static const proofBucket = 'delivery-proofs';
  final SupabaseClient client;

  Future<DeliveryBundle?> getDeliveryById(String deliveryId) =>
      _guard(() async {
        final value = await client.rpc<Object?>(
          'current_rider_deliveries',
          params: {'include_available': true},
        );
        for (final row in _deliveryRows(value)) {
          if (row['delivery_id'].toString() == deliveryId) {
            return DeliveryBundle.fromJson(row);
          }
        }
        return null;
      });

  Future<List<DeliveryBundle>> getAvailableDeliveries() => _guard(() async {
    final value = await client.rpc<Object?>(
      'current_rider_deliveries',
      params: {'include_available': true},
    );
    return _deliveryRows(value)
        .where((row) => row['assigned_to_current_rider'] != true)
        .map(DeliveryBundle.fromJson)
        .toList(growable: false);
  });

  Future<List<DeliveryBundle>> getAssignedDeliveries() => _guard(() async {
    final value = await client.rpc<Object?>(
      'current_rider_deliveries',
      params: {'include_available': false},
    );
    return _deliveryRows(
      value,
    ).map(DeliveryBundle.fromJson).toList(growable: false);
  });

  Future<List<DeliveryLocation>> getDeliveryLocations(String deliveryId) =>
      _guard(() async {
        final bundle = await getDeliveryById(deliveryId);
        return bundle?.locations ?? const [];
      });

  Future<DeliveryRequirement?> getDeliveryRequirements(String deliveryId) =>
      _guard(() async => null);

  Future<List<DeliveryStatusHistory>> getDeliveryStatusHistory(
    String deliveryId,
  ) => _guard(() async {
    final bundle = await getDeliveryById(deliveryId);
    return bundle?.history ?? const [];
  });

  Future<DeliveryPayment?> getDeliveryPayment(String deliveryId) =>
      _guard(() async => null);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(const Duration(seconds: 20));
    } on DeliveryDataException {
      rethrow;
    } on TimeoutException catch (error) {
      throw DeliveryDataException(
        DeliveryDataFailureType.timeout,
        'The delivery service timed out.',
        error,
      );
    } on SocketException catch (error) {
      throw DeliveryDataException(
        DeliveryDataFailureType.offline,
        'No network connection is available.',
        error,
      );
    } on StorageException catch (error) {
      throw DeliveryDataException(
        DeliveryDataFailureType.storage,
        error.message,
        error,
      );
    } on PostgrestException catch (error) {
      final type = error.code == '40001'
          ? DeliveryDataFailureType.conflict
          : error.code == '42501'
          ? DeliveryDataFailureType.authorization
          : error.code == '22023' || error.code == '23514'
          ? DeliveryDataFailureType.validation
          : DeliveryDataFailureType.database;
      throw DeliveryDataException(type, error.message, error);
    } on AuthException catch (error) {
      throw DeliveryDataException(
        DeliveryDataFailureType.authentication,
        error.message,
        error,
      );
    }
  }
}

List<Map<String, Object?>> _deliveryRows(Object? value) =>
    value is List ? value.map(_map).toList(growable: false) : const [];
