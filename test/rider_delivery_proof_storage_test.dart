import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/data/delivery_proof_storage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';

void main() {
  test(
    'delivery attestation returns only an opaque protected reference',
    () async {
      final storage = DeliveryProofStorage();

      final reference = await storage.saveAttestation(
        deliveryId: 'delivery-1',
        method: DeliveryConfirmationMethod.recipientName,
      );

      expect(reference, startsWith('protected://delivery/delivery-1/'));
      expect(reference, isNot(contains('Buyer One')));
    },
  );

  test('proof storage failure preserves completion as incomplete', () async {
    final storage = DeliveryProofStorage(failUploads: true);

    await expectLater(
      storage.saveAttestation(
        deliveryId: 'delivery-1',
        method: DeliveryConfirmationMethod.buyerConfirmation,
      ),
      throwsA(isA<DeliveryProofStorageException>()),
    );
  });
}
