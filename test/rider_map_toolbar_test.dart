import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('map refresh is reachable and disabled while loading', (
    tester,
  ) async {
    var refreshes = 0;
    for (final loading in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RiderMapToolbar(
              radiusKm: 15,
              onOpenList: () {},
              onRefresh: () => refreshes++,
              loading: loading,
            ),
          ),
        ),
      );
      final refresh = find.byTooltip(
        loading ? 'Refreshing map' : 'Refresh map',
      );
      expect(refresh, findsOneWidget);
      await tester.tap(refresh);
      await tester.pump();
      expect(refreshes, 1);
      expect(tester.takeException(), isNull);
    }
  });
}
