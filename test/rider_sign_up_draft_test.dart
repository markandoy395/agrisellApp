import 'package:agresell_app/features/rider/profile/data/rider_sign_up_draft_storage.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_registration_location.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  test('legacy personal-first drafts resume at account credentials', () {
    final restored = RiderSignUpDraft.fromJson({
      'step': 3,
      'values': {'firstName': 'Ana', 'email': 'ana@example.com'},
    });

    expect(restored.step, RiderSignUpStep.account);
    expect(restored.value(RiderSignUpFields.firstName), 'Ana');
    expect(restored.value(RiderSignUpFields.email), 'ana@example.com');
  });

  test('verified Rider recovery resumes at personal information', () async {
    final controller = RiderSignUpController(storage: _MemoryDraftStorage());
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.resumeVerifiedEmail('Rider@Example.com');

    expect(controller.draft.step, RiderSignUpStep.personal);
    expect(
      controller.draft.value(RiderSignUpFields.email),
      'rider@example.com',
    );
    expect(controller.emailVerified, isTrue);
  });

  test(
    'restores a Rider Sign-Up draft and never stores password data',
    () async {
      final storage = _MemoryDraftStorage();
      final controller = RiderSignUpController(storage: storage);
      addTearDown(controller.dispose);
      await controller.initialize();

      controller.updateValue(RiderSignUpFields.firstName, 'Ana');
      controller.updateValue(RiderSignUpFields.email, 'ana@example.com');
      controller.updateSensitive(
        password: 'Password1!',
        licenseNumber: 'N01-123',
      );
      await controller.editStep(RiderSignUpStep.vehicle);

      final restored = RiderSignUpController(storage: storage);
      addTearDown(restored.dispose);
      await restored.initialize();

      expect(restored.draft.step, RiderSignUpStep.vehicle);
      expect(restored.draft.value(RiderSignUpFields.firstName), 'Ana');
      expect(restored.draft.value(RiderSignUpFields.email), 'ana@example.com');
      expect(restored.password, isEmpty);
      expect(restored.licenseNumber, isEmpty);
      expect(storage.saved!.toJson().toString(), isNot(contains('Password1!')));
      expect(storage.saved!.toJson().toString(), isNot(contains('N01-123')));
    },
  );

  test('requires a written Rider address together with GPS coordinates', () {
    var draft = const RiderSignUpDraft()
        .withValue(RiderSignUpFields.latitude, '8.4822')
        .withValue(RiderSignUpFields.longitude, '124.6472')
        .withValue(RiderSignUpFields.location, '8.48220, 124.64720');

    expect(
      RiderSignUpValidator.stepError(
        draft: draft,
        step: RiderSignUpStep.address,
        licenseNumber: '',
        password: '',
        confirmPassword: '',
      ),
      'Enter your house, building, or street address.',
    );

    draft = draft
        .withValue(
          RiderSignUpFields.location,
          'Cogon, Cagayan de Oro City, Misamis Oriental',
        )
        .withValue(RiderSignUpFields.addressLine, '12 Rizal Street')
        .withValue(RiderSignUpFields.barangay, 'Cogon')
        .withValue(RiderSignUpFields.cityMunicipality, 'Cagayan de Oro City')
        .withValue(RiderSignUpFields.province, 'Misamis Oriental');
    expect(
      RiderSignUpValidator.stepError(
        draft: draft,
        step: RiderSignUpStep.address,
        licenseNumber: '',
        password: '',
        confirmPassword: '',
      ),
      isNull,
    );
  });

  test('Rider registration location prefers its written address', () {
    final location = RiderRegistrationLocation(
      latitude: 8.4822,
      longitude: 124.6472,
      accuracyMeters: 8,
      capturedAt: DateTime.utc(2026, 8, 3),
      address: 'Cogon, Cagayan de Oro City, Misamis Oriental',
    );

    expect(location.label, 'Cogon, Cagayan de Oro City, Misamis Oriental');
  });

  test('captures Rider exact location when leaving the address step', () async {
    final gps = _FakeGpsGateway();
    final controller = RiderSignUpController(
      storage: _MemoryDraftStorage(),
      gpsGateway: gps,
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.editStep(RiderSignUpStep.address);

    controller.updateValue(RiderSignUpFields.addressLine, '12 Rizal Street');
    controller.updateValue(RiderSignUpFields.barangay, 'Cogon');
    controller.updateValue(
      RiderSignUpFields.cityMunicipality,
      'Cagayan de Oro City',
    );
    controller.updateValue(RiderSignUpFields.province, 'Misamis Oriental');
    controller.updateValue(
      RiderSignUpFields.location,
      '12 Rizal Street, Barangay Cogon, Cagayan de Oro City, Misamis Oriental, Philippines',
    );

    expect(controller.canContinue, isTrue);
    expect(await controller.continueToNextStep(), isTrue);

    expect(gps.currentPositionCalls, 1);
    expect(controller.draft.step, RiderSignUpStep.vehicle);
    expect(controller.draft.value(RiderSignUpFields.latitude), '8.4822');
    expect(controller.draft.value(RiderSignUpFields.longitude), '124.6472');
    expect(controller.draft.value(RiderSignUpFields.locationAccuracy), '8.0');
    expect(
      controller.draft.value(RiderSignUpFields.locationCapturedAt),
      '2026-08-09T02:30:00.000Z',
    );
  });
}

class _MemoryDraftStorage implements RiderSignUpDraftStorage {
  RiderSignUpDraft? saved;

  @override
  Future<void> clear() async => saved = null;

  @override
  Future<RiderSignUpDraft?> load() async => saved;

  @override
  Future<void> save(RiderSignUpDraft draft) async => saved = draft;
}

Position _position() => Position(
  longitude: 124.6472,
  latitude: 8.4822,
  timestamp: DateTime.utc(2026, 8, 9, 2, 30),
  accuracy: 8,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

class _FakeGpsGateway implements GpsLocationGateway {
  var currentPositionCalls = 0;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<Position> currentPosition({required LocationSettings settings}) async {
    currentPositionCalls++;
    return _position();
  }

  @override
  Future<LocationAccuracyStatus> getAccuracyStatus() async =>
      LocationAccuracyStatus.precise;

  @override
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Stream<Position> positionStream({LocationSettings? settings}) =>
      const Stream<Position>.empty();

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;
}
