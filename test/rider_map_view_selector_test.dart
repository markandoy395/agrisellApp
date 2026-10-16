import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_map_visibility.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_view_selector.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_view_preview.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Poppins');
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
    ]) {
      fonts.addFont(
        rootBundle.load('assets/fonts/Poppins/Poppins-$weight.ttf'),
      );
    }
    await fonts.load();
  });

  testWidgets(
    'thumbnail cards select each map mode and survive unavailable tile images',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 240);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      var selected = RiderMapViewType.defaultView;
      final selections = <RiderMapViewType>[];
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: RepaintBoundary(
                key: boundaryKey,
                child: Material(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: StatefulBuilder(
                      builder: (context, setState) => RiderMapViewSelector(
                        selectedType: selected,
                        onSelect: (value) {
                          selections.add(value);
                          setState(() => selected = value);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(RiderMapViewPreview), findsNWidgets(3));
      expect(find.byType(Image), findsNWidgets(3));
      expect(find.byType(Icon), findsNothing);
      expect(tester.takeException(), isNull);
      for (final type in RiderMapViewType.values) {
        final card = find.byKey(ValueKey('map-view-${type.name}'));
        await tester.tap(card);
        await tester.pumpAndSettle();
        expect(selected, type);
        final semantics = tester
            .widgetList<Semantics>(
              find.ancestor(of: card, matching: find.byType(Semantics)),
            )
            .where((widget) => widget.properties.button == true);
        expect(
          semantics.any((widget) => widget.properties.selected == true),
          isTrue,
        );
      }
      expect(selections, RiderMapViewType.values);
      await tester.tap(find.byKey(const ValueKey('map-view-defaultView')));
      await tester.pumpAndSettle();
      final boundary =
          boundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      boundary.markNeedsPaint();
      await tester.pump();
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        final output = Directory('build/rider_map_previews')
          ..createSync(recursive: true);
        await File(
          '${output.path}/view_selector.png',
        ).writeAsBytes(png!.buffer.asUint8List());
        image.dispose();
      });
      tester.view.physicalSize = const Size(320, 260);
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Satellite'), findsOneWidget);
      expect(find.text('Terrain'), findsOneWidget);
    },
  );
}
