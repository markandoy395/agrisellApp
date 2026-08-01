import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';

class FarmerDirectoryRepository {
  const FarmerDirectoryRepository();

  static const _cover = 'assets/images/farm.jpg';
  static const _requestTimeout = Duration(seconds: 12);
  static const _followStateTimeout = Duration(seconds: 4);

  Future<List<FarmerProfile>> loadFarmers() async {
    if (!AgrisellSupabase.isInitialized) return const [];

    try {
      final followStates = _loadFollowStateRows();
      final directoryRows = await AgrisellSupabase.client
          .rpc('marketplace_farmer_directory')
          .timeout(_requestTimeout);
      return mergeRows(
        directoryRows: _rows(directoryRows),
        followStateRows: await followStates,
      );
    } on PostgrestException catch (error) {
      throw FarmerDirectoryException(error.message);
    } on TimeoutException {
      throw const FarmerDirectoryException(
        'The farmer directory took too long to respond.',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> _loadFollowStateRows() async {
    try {
      final response = await AgrisellSupabase.client
          .rpc('marketplace_farmer_follow_states')
          .timeout(_followStateTimeout);
      return _rows(response);
    } on Object {
      // Follow metadata is optional; the public farmer directory must remain
      // available while identity provisioning or this RPC is unavailable.
      return const [];
    }
  }

  static List<FarmerProfile> mergeRows({
    required List<Map<String, dynamic>> directoryRows,
    required List<Map<String, dynamic>> followStateRows,
  }) {
    final statesByFarm = {
      for (final state in followStateRows) _integer(state['farm_id']): state,
    };
    return [
      for (final row in directoryRows)
        farmerFromRow({
          ...row,
          if (statesByFarm[_integer(row['farm_id'])] case final state?)
            'follower_count': state['follower_count'],
          if (statesByFarm[_integer(row['farm_id'])] case final state?)
            'is_following': state['is_following'],
        }),
    ];
  }

  static FarmerProfile farmerFromRow(Map<String, dynamic> row) {
    final products = row['products'];
    return FarmerProfile(
      farmId: _integer(row['farm_id']),
      name: _text(row['farmer_name'], fallback: 'Farmer'),
      location: _text(row['farm_location'], fallback: 'Location unavailable'),
      rating: _number(row['rating']),
      coverImage: _cover,
      imageUrl: _optionalText(row['profile_image_url']),
      coverImageUrl: _optionalText(row['cover_image_url']),
      followerCount: _integer(row['follower_count'] ?? row['follow_count']),
      isFollowing: row['is_following'] == true,
      products: products is List
          ? products
                .whereType<Map<String, dynamic>>()
                .map(productFromRow)
                .toList(growable: false)
          : const [],
    );
  }

  static ProductAvailability productFromRow(Map<String, dynamic> row) =>
      ProductAvailability(
        name: _text(row['name'], fallback: 'Produce'),
        isAvailable: row['is_available'] == true,
      );

  static String _text(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String? _optionalText(Object? value) {
    final text = _text(value);
    return text.isEmpty ? null : text;
  }

  static double _number(Object? value) => switch (value) {
    num number => number.toDouble(),
    String text => double.tryParse(text) ?? 0,
    _ => 0,
  };

  static int _integer(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text) ?? 0,
    _ => 0,
  };

  static List<Map<String, dynamic>> _rows(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList(growable: false)
      : const [];
}

class FarmerDirectoryException implements Exception {
  const FarmerDirectoryException(this.message);

  final String message;
}
