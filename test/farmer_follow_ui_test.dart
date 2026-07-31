import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/buyer/home/data/farmer_directory_repository.dart';
import 'package:agresell_app/features/buyer/home/data/farmer_follow_repository.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_follow_state.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/farmer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buyer follows a farmer and can filter to followed farmers', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = FarmerFollowController(
      repository: _MemoryFollowRepository(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: FarmerScreen(
            farmerDirectoryRepository: const _FarmerDirectory(),
            followController: controller,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('follow-18')), findsOneWidget);
    expect(find.text('3 followers'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('follow-18')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('following-18')), findsOneWidget);
    expect(find.text('4 followers'), findsOneWidget);
    expect(find.text('You are now following Maria Santos.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Following'));
    await tester.pumpAndSettle();
    expect(find.text('Maria Santos'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('following-18')));
    await tester.pumpAndSettle();
    expect(find.text('0 farmers found'), findsOneWidget);
  });
}

class _FarmerDirectory extends FarmerDirectoryRepository {
  const _FarmerDirectory();

  @override
  Future<List<FarmerProfile>> loadFarmers() async => const [
    FarmerProfile(
      farmId: 18,
      name: 'Maria Santos',
      location: 'Bukidnon',
      rating: 4.8,
      coverImage: 'assets/images/farm.jpg',
      products: [ProductAvailability(name: 'Tomatoes', isAvailable: true)],
      followerCount: 3,
    ),
  ];
}

class _MemoryFollowRepository implements FarmerFollowRepository {
  var state = const FarmerFollowState(isFollowing: false, followerCount: 3);

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
