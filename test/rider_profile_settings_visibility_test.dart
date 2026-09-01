import 'package:agresell_app/features/rider/profile/presentation/screens/rider_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/rider_test_models.dart';

void main() {
  testWidgets('rider settings stay hidden until the settings icon is tapped', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(home: RiderProfileScreen(profile: verifiedRiderProfile())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Edit rider profile'), findsNothing);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Edit rider profile'), findsOneWidget);
    expect(find.text('Activity'), findsNothing);

    await tester.tap(find.byTooltip('Close settings'));
    await tester.pumpAndSettle();

    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Edit rider profile'), findsNothing);
  });
}
