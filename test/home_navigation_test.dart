import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/home_screen.dart';
import 'package:agresell_app/features/shared/widgets/navigation/custom_bottom_nav_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buyer navigation opens the searchable messages destination', (
    tester,
  ) async {
    await _pumpHome(tester, const Size(430, 932));

    final initialMessageTab = tester.widget<CustomBottomNavTab>(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomBottomNavTab && widget.item.label == 'Messages',
      ),
    );
    expect(initialMessageTab.badgeCount, 0);
    expect(initialMessageTab.isSelected, isFalse);

    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();

    expect(find.text('Search farmers or products'), findsOneWidget);
    expect(find.text('No conversations found'), findsOneWidget);

    final selectedMessageTab = tester.widget<CustomBottomNavTab>(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomBottomNavTab && widget.item.label == 'Messages',
      ),
    );
    expect(selectedMessageTab.badgeCount, 0);
    expect(selectedMessageTab.isSelected, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal swipe changes tabs while navigation stays visible', (
    tester,
  ) async {
    await _pumpHome(tester, const Size(320, 568));

    expect(find.text('Search in AgriSell'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.dragFrom(const Offset(160, 390), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('Search farmers or products'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Messages'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpHome(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AgrisellTheme.light,
      home: const HomeScreen(),
    ),
  );
  await tester.pumpAndSettle();
}
