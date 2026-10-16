import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'support/supabase_session_fixture.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_rider_evidence_uploader.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Source source;
  setUp(() async {
    source = _Source();
    await setTestSupabaseSession(source.client);
  });
  tearDown(() => source.client.dispose());
  test('saved camera proof completes through the remote repository', () async {
    final result = await SupabaseRiderDeliveryRepository(
      source.dataSource,
    ).completePickup(_command());
    expect(source.saved?['p_remarks'], 'pickup_method:productPhoto');
    expect(
      source.saved?['p_file_path'],
      'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa/7/pickup/productPhoto_123.jpg',
    );
    expect(result.status.currentStatus, DeliveryStatus.productPickedUp);
  });
  test('a real signed receipt is saved as signature proof', () async {
    final command = _command();
    command.proofReferences[PickupConfirmationMethod.farmerSignature] =
        'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa/7/pickup/riderSignature_123.jpg';
    final result = await SupabaseRiderDeliveryRepository(
      source.dataSource,
    ).completePickup(command);
    expect(source.saved?['p_type'], 'signature');
    expect(source.saved?['p_remarks'], 'pickup_method:farmerSignature');
    expect(result.status.currentStatus, DeliveryStatus.productPickedUp);
  });
  test(
    'legacy signature attestation never reaches the file proof RPC',
    () async {
      final command = _command();
      command.proofReferences[PickupConfirmationMethod.farmerSignature] =
          'protected://pickup/7/farmerSignature-123';
      await expectLater(
        SupabaseRiderDeliveryRepository(
          source.dataSource,
        ).completePickup(command),
        throwsA(
          isA<DeliveryDomainException>().having(
            (error) => error.message,
            'message',
            contains('Retake its photo'),
          ),
        ),
      );
      expect(source.saved?['p_type'], 'photo');
      expect(source.completed, isFalse);
    },
  );
  for (final error in [
    DeliveryDataFailureType.validation,
    DeliveryDataFailureType.database,
    DeliveryDataFailureType.authorization,
    DeliveryDataFailureType.conflict,
  ]) {
    test(
      'pickup preserves $error failures instead of the generic fallback',
      () async {
        source.failure = error;
        await expectLater(
          SupabaseRiderDeliveryRepository(
            source.dataSource,
          ).completePickup(_command()),
          throwsA(
            isA<DeliveryDomainException>().having(
              (value) => value.message,
              'message',
              'Specific proof or pickup failure',
            ),
          ),
        );
      },
    );
  }
  test(
    'offline pickup camera file uploads from the actual pickup directory',
    () async {
      final root = Directory('build/pickup_remote_proofs');
      await root.create(recursive: true);
      final file = File('${root.path}/pickup-productPhoto-123.jpg');
      await file.writeAsBytes([1, 2, 3]);
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async => root.absolute.path);
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final uploader = SupabaseRiderEvidenceUploader(source.dataSource);
      const reference = 'local-secure://pickup/7/pickup-productPhoto-123.jpg';
      expect(
        await uploader.resolve(
          reference: reference,
          deliveryId: '7',
          stage: DeliveryProofStage.pickup,
          type: DeliveryProofType.productPhoto,
        ),
        contains('/7/pickup/productPhoto_'),
      );
      expect(source.uploaded, containsAllInOrder([1, 2, 3]));
      await expectLater(
        uploader.resolve(
          reference: reference,
          deliveryId: '8',
          stage: DeliveryProofStage.pickup,
          type: DeliveryProofType.productPhoto,
        ),
        throwsA(isA<DeliveryDataException>()),
      );
      await uploader.removeLocal(reference);
      expect(await file.exists(), isFalse);
    },
  );
}

PickupCompletionCommand _command() => PickupCompletionCommand(
  deliveryId: '7',
  riderId: 'rider-a',
  idempotencyKey: 'pickup-key',
  location: DeliveryStatusLocation(
    latitude: 15.49,
    longitude: 120.97,
    accuracyMeters: 5,
    timestamp: DateTime.now(),
  ),
  checklist: const PickupConditionChecklist(
    correctProduct: true,
    correctQuantity: true,
    correctWeight: true,
    securePackaging: true,
    notVisiblyDamaged: true,
    matchesRequest: true,
    fitsVehicle: true,
    handlingInstructionsReceived: true,
    confirmedQuantity: 1,
    confirmedWeightKg: 5,
  ),
  proofReferences: {
    PickupConfirmationMethod.productPhoto:
        'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa/7/pickup/productPhoto_123.jpg',
  },
);

class _Source {
  _Source() {
    client = SupabaseClient(
      'https://example.test',
      'test-key',
      httpClient: MockClient(_respond),
    );
    dataSource = SupabaseDeliveryDataSource(client);
  }
  late final SupabaseClient client;
  late final SupabaseDeliveryDataSource dataSource;
  DeliveryDataFailureType? failure;
  Map<String, dynamic>? saved;
  Uint8List? uploaded;
  var completed = false;
  Future<http.Response> _respond(http.Request request) async {
    Object payload;
    var status = 200;
    if (request.url.path.contains('/storage/')) {
      uploaded = request.bodyBytes;
      payload = {'Key': 'delivery-proofs/test', 'Id': 'stored-photo'};
    } else if (request.url.path.endsWith(
      '/save_current_rider_delivery_proof',
    )) {
      saved = jsonDecode(request.body) as Map<String, dynamic>;
      payload = {
        'proof_id': 1,
        'delivery_id': 7,
        'proof_stage': 'pickup',
        'proof_type': 'photo',
        'file_path': saved!['p_file_path'],
        'created_at': '2026-10-15T01:00:00Z',
      };
    } else if (request.url.path.endsWith('/complete_pickup')) {
      if (failure != null) {
        status = 400;
        payload = {
          'code': failure == DeliveryDataFailureType.authorization
              ? '42501'
              : failure == DeliveryDataFailureType.conflict
              ? '40001'
              : failure == DeliveryDataFailureType.database
              ? 'PGRST202'
              : '22023',
          'message': 'Specific proof or pickup failure',
        };
      } else {
        completed = true;
        payload = {
          'history': {
            'status_history_id': 'pickup-key',
            'delivery_id': 7,
            'new_status': 'picked_up',
            'created_at': '2026-10-15T01:00:00Z',
          },
        };
      }
    } else {
      payload = [
        {
          'delivery_id': 7,
          'order_id': 9,
          'assigned_to_current_rider': true,
          'delivery_status': completed ? 'picked_up' : 'arrived_at_pickup',
          'created_at': '2026-10-15T01:00:00Z',
        },
      ];
    }
    return http.Response(
      jsonEncode(payload),
      status,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}
