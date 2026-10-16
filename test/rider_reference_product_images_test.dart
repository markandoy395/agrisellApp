import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/services/authenticated_storage_image.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_delivery_product_image.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_evidence_view.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_details.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_detail_product_card.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_product_image.dart';

const asset = 'assets/images/vege.jpeg';
const objectKey =
    '10000000-0000-0000-0000-000000000001/7/pickup/product_photo_123.jpg';
void main() {
  final wrappers = <String, Widget Function(String?)>{
    'Home active and nearby': (source) =>
        RiderDeliveryProductImage(path: source),
    'Requests, Active, History and Map': (source) =>
        RiderRequestProductImage(url: source, productName: 'Tomatoes'),
    'Delivery detail and pickup': (source) =>
        RiderDetailProductImage(url: source, productName: 'Tomatoes'),
  };
  for (final wrapper in wrappers.entries) {
    testWidgets('${wrapper.key} decodes actual product pixels', (tester) async {
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_host(const SizedBox()));
      // Cache each thumbnail size before mounting to finish real asset decoding.
      await tester.runAsync(() async {
        for (final width in [112, 124, 160]) {
          await precacheImage(
            ResizeImage(const AssetImage(asset), width: width),
            tester.element(find.byType(SizedBox).first),
          );
        }
      });
      await tester.pumpWidget(_host(wrapper.value('  $asset  ')));
      await tester.pumpAndSettle();
      expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as ResizeImage).height, isNull);
      expect(tester.takeException(), isNull);
    });
    testWidgets('${wrapper.key} authenticates project storage URLs', (
      tester,
    ) async {
      final url =
          '${AgrisellSupabase.projectUrl}/storage/v1/object/public/farmer-media/product.jpg';
      await tester.pumpWidget(_host(wrapper.value(url)));
      final provider =
          (tester.widget<Image>(find.byType(Image)).image as ResizeImage)
                  .imageProvider
              as NetworkImage;
      expect(provider.url, authenticatedStorageUrl(url));
      expect(provider.url, contains('/object/authenticated/farmer-media/'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'invalid and unsupported product references never become asset/network requests',
    (tester) async {
      for (final source in [
        null,
        '',
        '  ',
        'protected://proof/7',
        'local-secure://pickup/7/photo.jpg',
        'javascript:alert(1)',
        'assets/../secret.jpg',
      ]) {
        await tester.pumpWidget(
          _host(RiderProductImage(source: source, productName: 'Tomatoes')),
        );
        expect(find.byType(Image), findsNothing);
        expect(
          find.bySemanticsLabel('Tomatoes product image unavailable'),
          findsOneWidget,
        );
      }
    },
  );
  testWidgets('delivery detail renders private uploaded evidence as an image', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_evidence(objectKey)));
    final provider =
        (tester.widget<Image>(find.byType(Image)).image as ResizeImage)
                .imageProvider
            as NetworkImage;
    expect(
      Uri.parse(provider.url).path,
      '/storage/v1/object/authenticated/delivery-proofs/$objectKey',
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('delivery detail restores offline pickup evidence', (
    tester,
  ) async {
    final root = Directory('build/rider_reference_image_tests');
    late File file;
    await tester.runAsync(() async {
      await root.create(recursive: true);
      file = await File(asset).copy('${root.path}/pickup-productPhoto-123.jpg');
    });
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => root.absolute.path);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    await tester.pumpWidget(_host(const SizedBox()));
    await tester.runAsync(() async {
      final bytes = await file.readAsBytes();
      await precacheImage(
        ResizeImage(MemoryImage(bytes), width: 222),
        tester.element(find.byType(SizedBox).first),
      );
      await tester.pumpWidget(
        _host(_evidence('local-secure://pickup/7/pickup-productPhoto-123.jpg')),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    final provider =
        (tester.widget<Image>(find.byType(Image)).image as ResizeImage)
            .imageProvider;
    expect(provider, isA<MemoryImage>());
    // MemoryImage keys use byte identity, so finish this instance's decode too.
    await tester.runAsync(
      () => precacheImage(
        tester.widget<Image>(find.byType(Image)).image,
        tester.element(find.byType(Image)),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<RawImage>(find.byType(RawImage)).image, isNotNull);
  });
}

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);
Widget _evidence(String reference) => RiderDeliveryEvidenceView(
  proof: DeliveryProof(
    id: 'proof-7',
    type: DeliveryProofType.productPhoto,
    secureReference: reference,
    capturedAt: DateTime(2026, 10, 15),
  ),
);
