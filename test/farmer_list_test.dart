import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/buyer/home/data/farmer_directory_repository.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/farmer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('farmer list starts empty until backend profiles arrive', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const Scaffold(body: FarmerScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 farmers found'), findsOneWidget);
    expect(find.text('No farmers found'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Follow'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Shop'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search farmers, places, or produce'),
      'Bukidnon',
    );
    await tester.pumpAndSettle();
    expect(find.text('0 farmers found'), findsOneWidget);
    expect(find.text('No farmers found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('farmer directory failure can retry to loaded state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _RetryingFarmerDirectoryRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: FarmerScreen(farmerDirectoryRepository: repository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load farmers'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Maria Santos'), findsOneWidget);
    expect(repository.attempts, 2);
    expect(tester.takeException(), isNull);
  });
}

class _RetryingFarmerDirectoryRepository extends FarmerDirectoryRepository {
  var attempts = 0;

  @override
  Future<List<FarmerProfile>> loadFarmers() async {
    attempts++;
    if (attempts == 1) throw Exception('farmer directory unavailable');
    return const [
      FarmerProfile(
        farmId: 18,
        name: 'Maria Santos',
        location: 'Bukidnon',
        rating: 4.8,
        coverImage: 'assets/images/farm.jpg',
        products: [ProductAvailability(name: 'Tomatoes', isAvailable: true)],
      ),
    ];
  }
}
