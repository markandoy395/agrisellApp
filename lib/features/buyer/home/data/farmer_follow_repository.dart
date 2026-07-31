import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_follow_state.dart';

abstract interface class FarmerFollowRepository {
  Future<FarmerFollowState> loadState(int farmId);

  Future<FarmerFollowState> setFollowing({
    required int farmId,
    required bool isFollowing,
  });
}

class SupabaseFarmerFollowRepository implements FarmerFollowRepository {
  const SupabaseFarmerFollowRepository();

  static const _requestTimeout = Duration(seconds: 12);

  @override
  Future<FarmerFollowState> loadState(int farmId) {
    return _request('marketplace_farmer_follow_state', {'p_farm_id': farmId});
  }

  @override
  Future<FarmerFollowState> setFollowing({
    required int farmId,
    required bool isFollowing,
  }) {
    return _request('set_marketplace_farmer_follow', {
      'p_farm_id': farmId,
      'p_following': isFollowing,
    });
  }

  Future<FarmerFollowState> _request(
    String function,
    Map<String, Object> parameters,
  ) async {
    if (!AgrisellSupabase.isInitialized) {
      throw const FarmerFollowException('Following is currently unavailable.');
    }
    try {
      final response = await AgrisellSupabase.client
          .rpc(function, params: parameters)
          .timeout(_requestTimeout);
      if (response is! Map) {
        throw const FarmerFollowException('Invalid follow response.');
      }
      return stateFromJson(
        response.map((key, value) => MapEntry('$key', value)),
      );
    } on PostgrestException catch (error) {
      throw FarmerFollowException(error.message);
    } on TimeoutException {
      throw const FarmerFollowException(
        'The follow request took too long. Please try again.',
      );
    }
  }

  static FarmerFollowState stateFromJson(Map<String, dynamic> json) {
    final count = switch (json['follower_count'] ?? json['follow_count']) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value) ?? 0,
      _ => 0,
    };
    return FarmerFollowState(
      isFollowing: json['is_following'] == true,
      followerCount: count < 0 ? 0 : count,
    );
  }
}

class FarmerFollowException implements Exception {
  const FarmerFollowException(this.message);

  final String message;
}
