import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/pickup_proof_storage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'rider_detail_reference_fixture.dart';
import 'rider_test_models.dart';
import 'rider_availability_fakes.dart';

class PickupDesignFixture {
  PickupDesignFixture(
    this.request,
    this.repository,
    this.controller,
    this.location,
    this.storage,
  );
  final DeliveryRequest request;
  final InMemoryRiderDeliveryRepository repository;
  final RiderDeliveryController controller;
  final FakeRiderLocationController location;
  final PickupDesignProofStorage storage;
  static Future<PickupDesignFixture> create() async {
    final request = referenceDetailRequest(
      active: true,
    ).copyWith(stage: DeliveryStage.accepted);
    final repository = InMemoryRiderDeliveryRepository(
      requests: [request],
      pickupConfigurations: {
        request.id: PickupConfiguration(
          requiredMethods: {
            PickupConfirmationMethod.confirmationCode,
            PickupConfirmationMethod.qrCode,
            PickupConfirmationMethod.productPhoto,
          },
          pickupCodeHash: PickupConfiguration.hashCodeValue('246810'),
          qrPayloadHash: PickupConfiguration.hashQrPayload('pickup-qr'),
        ),
      },
    );
    var current = DeliveryStatus.accepted;
    for (final next in [
      DeliveryStatus.goingToPickup,
      DeliveryStatus.arrivedAtPickup,
      DeliveryStatus.waitingForProduct,
      DeliveryStatus.pickupConfirmationRequired,
    ]) {
      await repository.updateDeliveryStatus(
        DeliveryStatusUpdateCommand(
          deliveryId: request.id,
          riderId: 'rider-a',
          previousStatus: current,
          newStatus: next,
          idempotencyKey: next.name,
          location: DeliveryStatusLocation(
            latitude: 15.49,
            longitude: 120.97,
            accuracyMeters: 5,
            timestamp: DateTime.now(),
          ),
        ),
      );
      current = next;
    }
    final controller = RiderDeliveryController(repository: repository)
      ..updateProfile(verifiedRiderProfile());
    await controller.applyAuthoritativeAvailability(
      RiderAvailability.waitingAtPickup,
      loadRequests: false,
    );
    await controller.load(riderId: 'rider-a');
    final location = FakeRiderLocationController()
      ..fakeLocation = RiderDeviceLocation(
        latitude: 15.49,
        longitude: 120.97,
        accuracyMeters: 5,
        timestamp: DateTime.now(),
      );
    final storage = PickupDesignProofStorage();
    addTearDown(controller.dispose);
    addTearDown(location.dispose);
    return PickupDesignFixture(
      request,
      repository,
      controller,
      location,
      storage,
    );
  }
}

class PickupDesignProofStorage extends PickupProofStorage {
  var captureCalls = 0;
  var cancelCapture = false;
  @override
  String? get lastCapturedImagePath =>
      cancelCapture ? null : 'build/rider_pickup_test/proof.jpg';
  @override
  Future<String?> capturePhoto({
    required String deliveryId,
    required PickupConfirmationMethod method,
  }) async {
    captureCalls++;
    if (cancelCapture) return null;
    return 'protected://pickup/$deliveryId/${method.name}.jpg';
  }

  @override
  Future<String> saveAttestation({
    required String deliveryId,
    required PickupConfirmationMethod method,
  }) async => 'protected://pickup/$deliveryId/${method.name}';
}
