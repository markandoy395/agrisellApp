import 'package:agresell_app/features/buyer/home/data/farmer_follow_repository.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_follow_state.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const farmer = FarmerProfile(
    farmId: 8,
    name: 'Maria Farm',
    location: 'Bukidnon',
    rating: 4.7,
    coverImage: 'assets/images/farm.jpg',
    products: [],
    followerCount: 12,
  );

  test('toggle follows and unfollows a farmer using server state', () async {
    final repository = _MemoryFollowRepository();
    final controller = FarmerFollowController(repository: repository);
    controller.seed([farmer]);

    final followed = await controller.toggle(farmer);
    expect(followed.isFollowing, isTrue);
    expect(followed.followerCount, 13);
    expect(controller.stateFor(farmer), same(followed));

    final unfollowed = await controller.toggle(farmer);
    expect(unfollowed.isFollowing, isFalse);
    expect(unfollowed.followerCount, 12);
  });

  test('refresh replaces stale directory follow state', () async {
    final repository = _MemoryFollowRepository(
      initial: const FarmerFollowState(isFollowing: true, followerCount: 21),
    );
    final controller = FarmerFollowController(repository: repository);

    await controller.refresh(farmer);

    expect(controller.stateFor(farmer).isFollowing, isTrue);
    expect(controller.stateFor(farmer).followerCount, 21);
  });
}

class _MemoryFollowRepository implements FarmerFollowRepository {
  _MemoryFollowRepository({
    this.initial = const FarmerFollowState(
      isFollowing: false,
      followerCount: 12,
    ),
  }) : state = initial;

  final FarmerFollowState initial;
  FarmerFollowState state;

  @override
  Future<FarmerFollowState> loadState(int farmId) async => state;

  @override
  Future<FarmerFollowState> setFollowing({
    required int farmId,
    required bool isFollowing,
  }) async {
    state = FarmerFollowState(
      isFollowing: isFollowing,
      followerCount: state.followerCount + (isFollowing ? 1 : -1),
    );
    return state;
  }
}
