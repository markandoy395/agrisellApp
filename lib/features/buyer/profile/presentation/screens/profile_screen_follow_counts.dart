part of 'profile_screen.dart';

extension _ProfileScreenFollowCounts on _ProfileScreenState {
  void _refreshFollowCounts() => unawaited(_loadFollowCounts());

  Future<void> _loadFollowCounts() async {
    try {
      final counts = await const ProfileFollowCountsRepository().load();
      if (mounted) _updateUi(() => _followCounts = counts);
    } on ProfileFollowCountsException {
      // Keep zero-value placeholders when profile statistics are unavailable.
    }
  }
}
