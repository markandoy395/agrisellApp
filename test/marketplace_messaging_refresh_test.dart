import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/buyer/chat/presentation/screens/buyer_message_screen.dart';
import 'support/marketplace_messaging_fakes.dart';

void main() {
  testWidgets('auto refresh runs only while active and resumed', (
    tester,
  ) async {
    final repository = FakeMarketplaceMessagingRepository();
    final active = ValueNotifier<bool>(true);
    addTearDown(active.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: active,
            builder: (context, isActive, _) => BuyerMessageScreen(
              isActive: isActive,
              repository: repository,
              autoRefreshInterval: const Duration(seconds: 15),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.loadCalls, 1);

    await tester.pump(const Duration(seconds: 15));
    await tester.pump();
    expect(repository.loadCalls, 2);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    final pausedCalls = repository.loadCalls;
    await tester.pump(const Duration(seconds: 30));
    expect(repository.loadCalls, pausedCalls);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(repository.loadCalls, pausedCalls + 1);

    active.value = false;
    await tester.pumpAndSettle();
    final inactiveCalls = repository.loadCalls;
    await tester.pump(const Duration(seconds: 30));
    expect(repository.loadCalls, inactiveCalls);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
