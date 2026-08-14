import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_home_screen.dart';
import 'package:agresell_app/features/shared/orders/presentation/screens/notification_screen.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('farmer notifications keep state across tab switches', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FarmerHomeScreen(
          initialNavIndex: FarmerHomeScreen.notificationNavIndex,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final notificationState = tester.state(find.byType(NotificationScreen));

    await tester.tap(_navigationTab('Messages'));
    await tester.pumpAndSettle();
    expect(
      find.byType(NotificationScreen, skipOffstage: false),
      findsOneWidget,
    );

    await tester.tap(_navigationTab('Alerts'));
    await tester.pumpAndSettle();

    expect(
      tester.state(find.byType(NotificationScreen)),
      same(notificationState),
    );
  });
}

Finder _navigationTab(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is CustomBottomNavTab && widget.item.label == label,
  );
}
