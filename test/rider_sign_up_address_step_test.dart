import 'package:agresell_app/features/rider/profile/data/rider_sign_up_draft_storage.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_address_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Rider address step hides the exact map picker', (tester) async {
    final controller = RiderSignUpController(storage: _MemoryDraftStorage());
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.editStep(RiderSignUpStep.address);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RiderSignUpAddressStep(controller: controller)),
      ),
    );

    expect(find.text('Exact map location'), findsNothing);
    expect(find.text('Tap to pin your registered address'), findsNothing);
    expect(
      find.text(
        'Enter your official address by province, city or municipality, and barangay. We will capture your exact GPS location when you continue.',
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 500));
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
