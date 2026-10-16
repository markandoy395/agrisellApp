import 'package:flutter/material.dart';
import 'package:agresell_app/core/services/authenticated_storage_image.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Shared catalogue thumbnail for Home, Deliveries, Map, details and pickup.
class RiderProductImage extends StatelessWidget {
  const RiderProductImage({
    required this.source,
    required this.productName,
    this.dimension = 56,
    this.radius = const BorderRadius.all(Radius.circular(10)),
    this.unavailableLabel,
    super.key,
  });
  final String? source;
  final String productName;
  final double dimension;
  final BorderRadius radius;
  final String? unavailableLabel;

  Widget _fallback(BuildContext context, Object error, StackTrace? stack) =>
      Semantics(
        label: unavailableLabel ?? '$productName product image unavailable',
        child: const ColoredBox(
          color: AgrisellColors.forestSoft,
          child: Center(
            child: Icon(
              Icons.inventory_2_outlined,
              color: AgrisellColors.authGreen,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final value = source?.trim() ?? '';
    final uri = Uri.tryParse(value);
    final decodeWidth = (dimension * MediaQuery.devicePixelRatioOf(context))
        .ceil()
        .clamp(56, 320);
    final remote =
        uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'https' || uri.scheme == 'http');
    final Widget image;
    if (remote) {
      image = authenticatedNetworkImage(
        value,
        cacheWidth: decodeWidth,
        fit: BoxFit.cover,
        semanticLabel: '$productName product image',
        errorBuilder: _fallback,
      );
    } else if (value.startsWith('assets/') &&
        uri != null &&
        !uri.hasQuery &&
        !uri.hasFragment &&
        !value
            .split('/')
            .any(
              (segment) =>
                  segment == '..' || segment.toLowerCase().contains('%2e'),
            )) {
      image = Image.asset(
        value,
        cacheWidth: decodeWidth,
        fit: BoxFit.cover,
        semanticLabel: '$productName product image',
        errorBuilder: _fallback,
      );
    } else {
      image = _fallback(context, Object(), null);
    }
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox.square(dimension: dimension, child: image),
    );
  }
}
