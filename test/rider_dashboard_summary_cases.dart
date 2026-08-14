part of 'rider_dashboard_screen_test.dart';

void registerRiderDashboardSummaryCases() {
  testWidgets('dashboard stats stay visible while availability synchronizes', (
    tester,
  ) async {
    final repository = FakeRiderDashboardRepository(
      data: RiderDashboardData(
        metrics: const RiderDashboardMetrics(todayCompletedDeliveries: 2),
        fetchedAt: DateTime.now(),
        dataOrigin: RiderDataOrigin.backend,
        unavailableSections: const ['Communication counts'],
      ),
    );
    final fixture = RiderDashboardFixture(dashboardRepository: repository);
    addTearDown(fixture.dispose);
    await fixture.availability.initialize(riderId: 'rider-a');
    final saveGate = Completer<void>();
    fixture.availabilityRepository.saveGate = saveGate;

    await _pumpDashboard(tester, fixture);
    await tester.pumpAndSettle();
    fixture.delivery.setOnline(true);
    await tester.pump();

    expect(fixture.availability.isSynchronizing, isTrue);
    expect(find.text('Dashboard stats'), findsOneWidget);
    expect(find.text('Synchronizing availability'), findsNothing);

    saveGate.complete();
    await tester.pumpAndSettle();
  });

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
    expect(find.text('Dashboard stats'), findsOneWidget);
    expect(find.text('Partial dashboard data'), findsNothing);
    expect(
      find.text('Some sections are unavailable. Pull down to refresh.'),
      findsNothing,
    );
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Earnings'), findsOneWidget);

    final refreshGate = Completer<void>();
    repository.gate = refreshGate;
    final refresh = fixture.dashboard.refresh();
    await tester.pump();

    expect(fixture.dashboard.state, RiderDashboardLoadState.refreshing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Dashboard stats'), findsOneWidget);

    refreshGate.complete();
    await refresh;
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('PHP 0.00'), findsWidgets);
    expect(find.text('Messages (0)'), findsOneWidget);
    expect(find.text('Notifications (0)'), findsOneWidget);
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
    final locationRefreshes = fixture.location.refreshCalls;

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(repository.fetchCalls, 2);
    expect(fixture.location.refreshCalls, locationRefreshes);
    expect(find.textContaining('No active delivery'), findsOneWidget);
  });
}
