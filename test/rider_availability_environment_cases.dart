part of 'rider_availability_guards_test.dart';

void registerRiderAvailabilityEnvironmentCases() {
  test('GPS disabled blocks going online with a clear warning', () async {
    final harness = await _Harness.create(
      locationState: RiderLocationState.serviceDisabled,
    );
    addTearDown(harness.dispose);

    final result = await harness.availability.setOnline(true);

    expect(result.isSuccess, isFalse);
    expect(result.warning, RiderAvailabilityWarning.gpsDisabled);
    expect(harness.repository.saveCalls, 0);
  });

  test('permission denied blocks going online', () async {
    final harness = await _Harness.create(
      locationState: RiderLocationState.permissionDenied,
    );
    addTearDown(harness.dispose);

    final result = await harness.availability.setOnline(true);

    expect(result.isSuccess, isFalse);
    expect(result.warning, RiderAvailabilityWarning.locationPermissionDenied);
    expect(harness.repository.saveCalls, 0);
  });

  test('permanently denied permission directs Rider to settings', () async {
    final harness = await _Harness.create(
      locationState: RiderLocationState.permissionDeniedForever,
    );
    addTearDown(harness.dispose);

    final result = await harness.availability.setOnline(true);

    expect(result.isSuccess, isFalse);
    expect(
      result.warning,
      RiderAvailabilityWarning.locationPermissionDeniedForever,
    );
    expect(harness.repository.saveCalls, 0);
  });

  test('approximate location blocks Online and Available', () async {
    final harness = await _Harness.create(
      locationState: RiderLocationState.approximateLocation,
    );
    addTearDown(harness.dispose);

    final result = await harness.availability.setOnline(true);

    expect(result.isSuccess, isFalse);
    expect(result.warning, RiderAvailabilityWarning.approximateLocation);
    expect(harness.repository.saveCalls, 0);
  });

  test('location timeout returns an actionable typed warning', () async {
    final harness = await _Harness.create(
      locationState: RiderLocationState.timedOut,
    );
    addTearDown(harness.dispose);

    final result = await harness.availability.setOnline(true);

    expect(result.isSuccess, isFalse);
    expect(result.warning, RiderAvailabilityWarning.locationTimeout);
    expect(harness.repository.saveCalls, 0);
  });

  test('no internet blocks status synchronization', () async {
    final harness = await _Harness.create(isOnline: false);
    addTearDown(harness.dispose);

    final result = await harness.availability.setOnline(true);

    expect(result.isSuccess, isFalse);
    expect(result.warning, RiderAvailabilityWarning.noInternet);
    expect(harness.availability.internetStatus, RiderInternetStatus.offline);
    expect(harness.repository.saveCalls, 0);
  });

  test('backend unavailable is distinct from no internet', () async {
    final harness = await _Harness.create(
      connectivityStatus: RiderInternetStatus.backendUnavailable,
    );
    addTearDown(harness.dispose);

    final result = await harness.availability.setOnline(true);

    expect(result.isSuccess, isFalse);
    expect(result.warning, RiderAvailabilityWarning.backendUnavailable);
    expect(
      harness.availability.internetStatus,
      RiderInternetStatus.backendUnavailable,
    );
    expect(harness.repository.saveCalls, 0);
  });

  test('initial environment refresh does not prompt for permission', () async {
    final harness = await _Harness.create(
      locationState: RiderLocationState.permissionDenied,
    );
    addTearDown(harness.dispose);

    expect(harness.location.refreshCalls, 1);
    expect(harness.location.permissionRequestCalls, 0);

    await harness.availability.setOnline(true);
    expect(harness.location.permissionRequestCalls, 1);
  });
}
