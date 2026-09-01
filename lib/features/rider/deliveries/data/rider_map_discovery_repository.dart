import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';

abstract interface class RiderMapDiscoveryRepository {
  Future<List<RiderNearbyFarm>> fetchNearbyFarms(RiderDeliverySearch search);
}

class SupabaseRiderMapDiscoveryRepository
    implements RiderMapDiscoveryRepository {
  const SupabaseRiderMapDiscoveryRepository(this.client);

  final SupabaseClient client;

  @override
  Future<List<RiderNearbyFarm>> fetchNearbyFarms(
    RiderDeliverySearch search,
  ) async {
    try {
      final value = await client
          .rpc<Object?>(
            'current_rider_nearby_farms',
            params: {
              'p_latitude': search.latitude,
              'p_longitude': search.longitude,
              'p_radius_km': search.radiusKm,
              'p_limit': 50,
            },
          )
          .timeout(const Duration(seconds: 20));
      if (value is! List) return const [];
      return value
          .whereType<Map>()
          .map((row) => _farm(Map<String, Object?>.from(row)))
          .whereType<RiderNearbyFarm>()
          .toList(growable: false);
    } on TimeoutException {
      throw const RiderMapDiscoveryException(
        'Nearby farms took too long to load.',
      );
    } on SocketException {
      throw const RiderMapDiscoveryException(
        'Nearby farms are unavailable while offline.',
      );
    } on PostgrestException catch (error) {
      throw RiderMapDiscoveryException(error.message);
    }
  }

  RiderNearbyFarm? _farm(Map<String, Object?> row) {
    final latitude = _number(row['latitude']);
    final longitude = _number(row['longitude']);
    final distanceKm = _number(row['distance_km']);
    if (latitude == null || longitude == null || distanceKm == null) {
      return null;
    }
    final crops = row['main_crops'];
    return RiderNearbyFarm(
      id: '${row['farm_id']}',
      name: _text(row['farm_name']) ?? 'Farm',
      address: _text(row['farm_location']) ?? 'Farm pickup location',
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      mainCrops: crops is List
          ? crops
                .map((value) => '$value'.trim())
                .where((value) => value.isNotEmpty)
                .toList(growable: false)
          : const [],
    );
  }
}

class InMemoryRiderMapDiscoveryRepository
    implements RiderMapDiscoveryRepository {
  const InMemoryRiderMapDiscoveryRepository({this.farms = const []});

  final List<RiderNearbyFarm> farms;

  @override
  Future<List<RiderNearbyFarm>> fetchNearbyFarms(
    RiderDeliverySearch search,
  ) async => farms
      .where(
        (farm) =>
            search.distanceTo(
              latitude: farm.latitude,
              longitude: farm.longitude,
            ) <=
            search.radiusKm,
      )
      .toList(growable: false);
}

class RiderMapDiscoveryException implements Exception {
  const RiderMapDiscoveryException(this.message);
  final String message;
}

double? _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');

String? _text(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
