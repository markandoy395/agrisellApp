import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/auth/presentation/widgets/logo_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('one explicit dimension preserves the intrinsic decode ratio', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 100,
            height: 80,
            child: ResponsiveAssetImage(
              asset: 'assets/images/vege.jpeg',
              width: 100,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as ResizeImage;
    expect(provider.width, 200);
    expect(provider.height, isNull);
  });

  testWidgets('login logo keeps its natural height under loose constraints', (
    tester,
  ) async {
    const asset = 'assets/logo/agrisellLandscapeLogoWithOutTagline.png';
    final aspectRatio = await tester.runAsync(() async {
      final bytes = await rootBundle.load(asset);
      final original = await decodeImageFromList(bytes.buffer.asUint8List());
      final ratio = original.width / original.height;
      original.dispose();
      return ratio;
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              LogoHeader(widthMin: 120, widthMax: 120),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await precacheImage(
        tester.widget<Image>(find.byType(Image)).image,
        tester.element(find.byType(Image)),
      );
    });
    await tester.pumpAndSettle();

    final size = tester.getSize(find.byType(Image));
    expect(size.width, 120);
    expect(size.height, closeTo(120 / aspectRatio!, 1));
    final provider =
        tester.widget<Image>(find.byType(Image)).image as ResizeImage;
    expect(provider.height, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('decode sizes respect the memory caps and explicit overrides', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveAssetImage(
          asset: 'assets/images/vege.jpeg',
          width: 100,
          height: 80,
          maxDecodedWidth: 64,
          decodeHeight: 32,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final provider =
        tester.widget<Image>(find.byType(Image)).image as ResizeImage;
    expect(provider.width, 64);
    expect(provider.height, 32);
  });
}
