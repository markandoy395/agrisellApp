import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/rider_map_visibility.dart';
import '../styles/rider_live_map_styles.dart';
import '../styles/rider_map_view_styles.dart';

class RiderMapViewPreview extends StatelessWidget {
  const RiderMapViewPreview({required this.type, super.key});
  final RiderMapViewType type;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: RiderMapViewStyles.thumbnailRadius,
    child: AspectRatio(
      aspectRatio: 1.65,
      child: Image.network(
        RiderMapViewStyles.previewUrl(type),
        headers: kIsWeb
            ? null
            : const {'User-Agent': RiderLiveMapStyles.osmUserAgent},
        cacheWidth: 256,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        loadingBuilder: (_, image, progress) =>
            progress == null ? image : _fallback,
        errorBuilder: (_, _, _) => _fallback,
      ),
    ),
  );

  Widget get _fallback => CustomPaint(painter: _MapPreviewPainter(type));
}

// Lightweight illustrative previews keep the cards recognizable while offline.
class _MapPreviewPainter extends CustomPainter {
  const _MapPreviewPainter(this.type);
  final RiderMapViewType type;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(RiderMapViewStyles.land(type), BlendMode.src);
    if (type == RiderMapViewType.satellite) {
      for (var row = 0; row < 5; row++) {
        for (var column = 0; column < 7; column++) {
          canvas.drawRect(
            Rect.fromLTWH(
              column * size.width / 7,
              row * size.height / 5,
              size.width / 7 - 2,
              size.height / 5 - 2,
            ),
            RiderMapViewStyles.field(row * 3 + column),
          );
        }
      }
    } else if (type == RiderMapViewType.terrain) {
      for (var index = 0; index < 7; index++) {
        final path = Path()..moveTo(-10, size.height * index / 6);
        path.cubicTo(
          size.width * .3,
          size.height * (index - 3) / 6,
          size.width * .55,
          size.height * (index + 3) / 6,
          size.width + 10,
          size.height * index / 6,
        );
        canvas.drawPath(path, RiderMapViewStyles.contour);
      }
    } else {
      canvas.drawRect(
        Rect.fromLTWH(size.width * .57, 0, size.width * .43, size.height * .85),
        RiderMapViewStyles.park,
      );
      final water = Path()
        ..moveTo(size.width * .78, size.height)
        ..cubicTo(
          size.width * .45,
          size.height * .4,
          size.width * 1.1,
          size.height * .7,
          size.width * .95,
          0,
        )
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(water, RiderMapViewStyles.water);
    }
    final road = RiderMapViewStyles.road(type, size.width * .055);
    canvas.drawLine(
      Offset(-10, size.height * .85),
      Offset(size.width, size.height * .15),
      road,
    );
    canvas.drawLine(
      Offset(size.width * .2, -5),
      Offset(size.width * .5, size.height + 5),
      road,
    );
    canvas.drawLine(
      Offset(size.width * .68, -5),
      Offset(size.width * .78, size.height + 5),
      road,
    );
  }

  @override
  bool shouldRepaint(_MapPreviewPainter oldDelegate) =>
      oldDelegate.type != type;
}
