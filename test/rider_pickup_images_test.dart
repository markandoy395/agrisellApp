import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/services/authenticated_storage_image.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/deliveries/data/pickup_proof_storage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_proof_image_reference.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_detail_product_card.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_pickup_proof_image.dart';

const objectKey =
    '10000000-0000-0000-0000-000000000001/7/pickup/product_photo_123.jpg';
const localRef = 'local-secure://pickup/7/pickup-productPhoto-123.jpg';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final root = Directory('build/rider_pickup_images_test');
  late File photo;
  setUpAll(() async {
    await root.create(recursive: true);
    photo = await File(
      'assets/images/vege.jpeg',
    ).copy('${root.path}/pickup-productPhoto-123.jpg');
  });
  test(
    'private upload keys resolve to authenticated objects without signed URLs',
    () {
      final uri = Uri.parse(riderProofImageUrl(objectKey)!);
      expect(
        uri.path,
        '/storage/v1/object/authenticated/delivery-proofs/$objectKey',
      );
      expect(uri.query, isEmpty);
      expect(storageImageHeaders('https://external.test/photo.jpg'), isNull);
      expect(
        riderProofImageUrl('https://external.test/photo.jpg'),
        'https://external.test/photo.jpg',
      );
    },
  );
  test('non-image attestations and unsafe upload keys are never fetched', () {
    for (final value in [
      localRef,
      'protected://pickup/7/signature',
      '../private.jpg',
      objectKey.replaceFirst('/7/', '/../'),
      '$objectKey?token=unsafe',
      objectKey.replaceFirst('.jpg', '.svg'),
      objectKey.replaceFirst('pickup', 'unknown'),
      objectKey.replaceFirst('product_photo_123.jpg', '%2e%2e%2fprivate.jpg'),
    ]) {
      expect(riderProofImageUrl(value), isNull, reason: value);
    }
  });
  test(
    'offline pickup images resolve inside documents with strict filenames',
    () async {
      const channel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (call) async => root.absolute.path,
          );
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final storage = PickupProofStorage();
      expect(
        (await storage.resolveLocalPhoto(localRef))?.absolute.path,
        photo.absolute.path,
      );
      final signature = await photo.copy(
        '${root.path}/pickup-farmerSignature-123.jpg',
      );
      addTearDown(() => signature.delete());
      expect(
        (await storage.resolveLocalPhoto(
          'local-secure://pickup/7/pickup-farmerSignature-123.jpg',
        ))?.absolute.path,
        signature.absolute.path,
      );
      for (final value in [
        'local-secure://delivery/7/pickup-productPhoto-123.jpg',
        'local-secure://pickup/7/%2e%2e%2fprivate.jpg',
        'local-secure://pickup/7/private.jpg',
        '$localRef?path=other',
        'local-secure://pickup/7/pickup-productPhoto-999.jpg',
      ]) {
        expect(await storage.resolveLocalPhoto(value), isNull);
      }
    },
  );
  test('signature proof cannot be replaced by a tap attestation', () async {
    expect(PickupConfirmationMethod.farmerSignature.requiresImage, isTrue);
    await expectLater(
      PickupProofStorage().saveAttestation(
        deliveryId: '7',
        method: PickupConfirmationMethod.farmerSignature,
      ),
      throwsA(isA<PickupProofStorageException>()),
    );
    expect(
      await PickupProofStorage().saveAttestation(
        deliveryId: '7',
        method: PickupConfirmationMethod.farmerConfirmation,
      ),
      startsWith('protected://pickup/7/'),
    );
  });
  testWidgets(
    'restored photo renders actual pixels and loads once per reference',
    (tester) async {
      var loads = 0;
      Future<File?> resolve(String _) async {
        loads++;
        return photo;
      }

      await tester.pumpWidget(_host(const SizedBox()));
      final context = tester.element(find.byType(SizedBox).first);
      await tester.runAsync(
        () => precacheImage(ResizeImage(FileImage(photo), width: 270), context),
      );
      Widget preview(String reference) => _host(
        RiderPickupProofImage(reference: reference, resolveLocalPhoto: resolve),
      );
      await tester.pumpWidget(preview(localRef));
      await tester.pumpAndSettle();
      expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
      await tester.pumpWidget(preview(localRef));
      await tester.pump(const Duration(seconds: 2));
      expect(loads, 1);
      await tester.pumpWidget(preview(localRef.replaceFirst('/7/', '/8/')));
      await tester.pumpAndSettle();
      expect(loads, 2);
      await tester.pumpWidget(preview('protected://pickup/7/no-image'));
      await tester.pumpAndSettle();
      expect(find.byType(RawImage), findsNothing);
      expect(
        find.bySemanticsLabel('Photo preview unavailable'),
        findsOneWidget,
      );
    },
  );
  testWidgets('restored private object paths request the authenticated image', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const RiderPickupProofImage(reference: objectKey)),
    );
    final image = tester.widget<Image>(find.byType(Image));
    final provider = (image.image as ResizeImage).imageProvider as NetworkImage;
    expect(provider.url, riderProofImageUrl(objectKey));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Photo preview unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'product thumbnail decodes its image and labels missing data honestly',
    (tester) async {
      await tester.pumpWidget(_host(const SizedBox()));
      await tester.runAsync(
        () => precacheImage(
          const ResizeImage(AssetImage('assets/images/vege.jpeg'), width: 240),
          tester.element(find.byType(SizedBox).first),
        ),
      );
      await tester.pumpWidget(
        _host(
          const RiderDetailProductImage(
            url: 'assets/images/vege.jpeg',
            productName: 'Fresh vegetables',
          ),
        ),
      );
      // The test DPR is 3; the thumbnail's bounded decode width is 240.
      await tester.pumpAndSettle();
      expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
      await tester.pumpWidget(
        _host(
          const RiderDetailProductImage(
            url: null,
            productName: 'Fresh vegetables',
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Fresh vegetables image unavailable'),
        findsOneWidget,
      );
    },
  );
}

Widget _host(Widget child) => MaterialApp(
  theme: AgrisellTheme.light,
  home: Scaffold(body: Center(child: child)),
);
