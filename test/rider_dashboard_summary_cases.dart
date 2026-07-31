part of 'rider_dashboard_screen_test.dart';

void registerRiderDashboardSummaryCases() {
  testWidgets('partial sections show honest unavailable values', (
    tester,
  ) async {
    final repository = FakeRiderDashboardRepository(
      data: RiderDashboardData(
        metrics: const RiderDashboardMetrics(),
        fetchedAt: DateTime.now(),
        dataOrigin: RiderDataOrigin.backend,
        unavailableSections: const [
          'Today metrics',
          'Earnings',
          'Communication counts',
        ],
      ),
    );
    final fixture = RiderDashboardFixture(dashboardRepository: repository);
    addTearDown(fixture.dispose);

    await _pumpDashboard(tester, fixture);
    await tester.pumpAndSettle();
    expect(find.text('Partial dashboard data'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Not available'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Messages (0)'), findsNothing);
  });

  testWidgets('metrics expose counts, earnings, communication, and safety', (
    tester,
  ) async {
    final repository = FakeRiderDashboardRepository(
      data: backendDashboardData(
        metrics: const RiderDashboardMetrics(
          todayCompletedDeliveries: 3,
          todayEstimatedEarnings: 250,
          unreadMessageCount: 2,
          unreadNotificationCount: 4,
          pendingEarnings: 100,
          onTimeDeliveryRate: 96,
        ),
      ),
    );
    final fixture = RiderDashboardFixture(dashboardRepository: repository);
    addTearDown(fixture.dispose);
    var earningsOpened = false;
    var messagesOpened = false;
    var notificationsOpened = false;
    var safetyOpened = false;

    await _pumpDashboard(
      tester,
      fixture,
      onOpenEarnings: () => earningsOpened = true,
      onOpenMessages: () => messagesOpened = true,
      onOpenNotifications: () => notificationsOpened = true,
      onSafetySupport: () => safetyOpened = true,
    );
    await tester.pumpAndSettle();

    expect(find.text('PHP 250.00'), findsOneWidget);
    expect(find.text('PHP 100.00 pending'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.tap(find.text('Messages (2)'));
    await tester.tap(find.text('Notifications (4)'));
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Safety and support'));

    expect(earningsOpened, isTrue);
    expect(messagesOpened, isTrue);
    expect(notificationsOpened, isTrue);
    expect(safetyOpened, isTrue);
    expect(find.textContaining('On-time rate: 96.0%'), findsOneWidget);
  });

  testWidgets('pull to refresh performs one lightweight dashboard request', (
    tester,
  ) async {
    final repository = FakeRiderDashboardRepository();
    final fixture = RiderDashboardFixture(dashboardRepository: repository);
    addTearDown(fixture.dispose);
    await _pumpDashboard(tester, fixture);
    await tester.pumpAndSettle();
    expect(repository.fetchCalls, 1);

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(repository.fetchCalls, 2);
    expect(find.textContaining('No active delivery'), findsOneWidget);
  });
}
