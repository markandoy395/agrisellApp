import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/widgets/image_loading_skeleton.dart';
import 'package:agresell_app/features/shared/notifications/presentation/widgets/notification_grouped_list.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_grid_skeleton.dart';

void main() {
  testWidgets('large grouped feed builds visible rows and can reach the end', (
    tester,
  ) async {
    final built = <int>{};
    final now = DateTime.now();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationGroupedList<int>(
            items: List.generate(1000, (index) => index),
            dateOf: (index) =>
                index < 500 ? now : now.subtract(const Duration(days: 3)),
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              built.add(index);
              return SizedBox(height: 80, child: Text('Update $index'));
            },
          ),
        ),
      ),
    );
    expect(built.length, lessThan(40));
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Update 999'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Update 999'),
      500,
      maxScrolls: 250,
    );
    expect(find.text('Update 999'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final grid in [false, true]) {
    testWidgets('${grid ? 'grid' : 'image'} shimmer stops and resumes', (
      tester,
    ) async {
      Widget subject({bool reduced = false, bool visible = true}) =>
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: TickerMode(
                enabled: visible,
                child: Scaffold(
                  body: grid
                      ? const CustomScrollView(
                          slivers: [HomeProductGridSkeleton()],
                        )
                      : const SizedBox(
                          width: 100,
                          height: 100,
                          child: ImageLoadingSkeleton(),
                        ),
                ),
              ),
            ),
          );

      await tester.pumpWidget(subject());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(subject(reduced: true));
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(subject());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(subject(visible: false));
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }
}
