import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/buyer/home/data/farmer_follow_repository.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_follow_state.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';

class FarmerFollowController extends ChangeNotifier {
  FarmerFollowController({
    this.repository = const SupabaseFarmerFollowRepository(),
  });

  static final FarmerFollowController instance = FarmerFollowController();

  final FarmerFollowRepository repository;
  final ValueNotifier<int> successfulChanges = ValueNotifier<int>(0);
  final Map<int, FarmerFollowState> _states = {};
  final Set<int> _busyFarmIds = {};

  FarmerFollowState stateFor(FarmerProfile farmer) =>
      _states[farmer.farmId] ??
      FarmerFollowState(
        isFollowing: farmer.isFollowing,
        followerCount: farmer.followerCount,
      );

  bool isBusy(int farmId) => _busyFarmIds.contains(farmId);

  void seed(Iterable<FarmerProfile> farmers) {
    for (final farmer in farmers) {
      if (_busyFarmIds.contains(farmer.farmId)) continue;
      _states.putIfAbsent(
        farmer.farmId,
        () => FarmerFollowState(
          isFollowing: farmer.isFollowing,
          followerCount: farmer.followerCount,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> refresh(FarmerProfile farmer) async {
    _states.putIfAbsent(
      farmer.farmId,
      () => FarmerFollowState(
        isFollowing: farmer.isFollowing,
        followerCount: farmer.followerCount,
      ),
    );
    await _perform(farmer.farmId, () => repository.loadState(farmer.farmId));
  }

  Future<FarmerFollowState> toggle(FarmerProfile farmer) async {
    final current = stateFor(farmer);
    return _perform(
      farmer.farmId,
      () => repository.setFollowing(
        farmId: farmer.farmId,
        isFollowing: !current.isFollowing,
      ),
    );
  }

  Future<FarmerFollowState> _perform(
    int farmId,
    Future<FarmerFollowState> Function() operation,
  ) async {
    if (_busyFarmIds.contains(farmId)) return _states[farmId]!;
    _busyFarmIds.add(farmId);
    notifyListeners();
    try {
      final state = await operation();
      _states[farmId] = state;
      successfulChanges.value++;
      return state;
    } finally {
      _busyFarmIds.remove(farmId);
      notifyListeners();
    }
  }

  void unload() {
    _states.clear();
    _busyFarmIds.clear();
    notifyListeners();
  }
}
