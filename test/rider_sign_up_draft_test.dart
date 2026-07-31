import 'package:agresell_app/features/rider/profile/data/rider_sign_up_draft_storage.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
