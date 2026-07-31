import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/profile/domain/profile_follow_counts.dart';

class ProfileFollowCountsRepository {
  const ProfileFollowCountsRepository();

  static const _requestTimeout = Duration(seconds: 12);

  Future<ProfileFollowCounts> load() async {
    if (!AgrisellSupabase.isInitialized) {
      return const ProfileFollowCounts();
    }
    try {
      final response = await AgrisellSupabase.client
          .rpc('current_profile_follow_stats')
          .timeout(_requestTimeout);
      if (response is! Map) return const ProfileFollowCounts();
      return countsFromJson(
        response.map((key, value) => MapEntry('$key', value)),
      );
    } on PostgrestException catch (error) {
      throw ProfileFollowCountsException(error.message);
    } on TimeoutException {
      throw const ProfileFollowCountsException(
        'Follow statistics took too long to load.',
      );
    }
  }

  static ProfileFollowCounts countsFromJson(Map<String, dynamic> json) {
    return ProfileFollowCounts(
      followingCount: _count(json['following_count']),
      followerCount: _count(json['follower_count']),
    );
  }

  static int _count(Object? value) {
    final count = switch (value) {
      int number => number,
      num number => number.toInt(),
      String text => int.tryParse(text) ?? 0,
      _ => 0,
    };
    return count < 0 ? 0 : count;
  }
}

class ProfileFollowCountsException implements Exception {
  const ProfileFollowCountsException(this.message);

  final String message;
}
