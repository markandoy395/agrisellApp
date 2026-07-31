import 'package:agresell_app/features/shared/profile/data/profile_follow_counts_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps persisted profile following and follower counts', () {
    final counts = ProfileFollowCountsRepository.countsFromJson({
      'following_count': '7',
      'follower_count': 19,
    });

    expect(counts.followingCount, 7);
    expect(counts.followerCount, 19);
  });

  test('clamps invalid and negative counts to zero', () {
    final counts = ProfileFollowCountsRepository.countsFromJson({
      'following_count': -2,
      'follower_count': 'invalid',
    });

    expect(counts.followingCount, 0);
    expect(counts.followerCount, 0);
  });
}
