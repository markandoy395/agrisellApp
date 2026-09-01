import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/presentation/rider_map_camera_policy.dart';

void main() {
  group('RiderMapCameraPolicy', () {
    test('route padding always leaves a positive drawable viewport', () {
      for (final viewport in const [
        Size(326, 352),
        Size(326, 100),
        Size(40, 23),
      ]) {
        final padding = RiderMapCameraPolicy.routeFitPadding(viewport)!;

        expect(padding.horizontal, lessThan(viewport.width));
        expect(padding.vertical, lessThan(viewport.height));
      }
    });

    test('rejects invalid viewports and coordinates', () {
      expect(RiderMapCameraPolicy.routeFitPadding(Size.zero), isNull);
      expect(
        RiderMapCameraPolicy.routeFitPadding(const Size(double.nan, 300)),
        isNull,
      );
      expect(RiderMapCameraPolicy.isCoordinateValid(double.nan, 120), isFalse);
      expect(RiderMapCameraPolicy.isCoordinateValid(91, 120), isFalse);
    });

    test('replaces non-finite zoom and clamps finite zoom', () {
      expect(RiderMapCameraPolicy.safeZoom(double.infinity), 15);
      expect(RiderMapCameraPolicy.safeZoom(-20), 4);
      expect(RiderMapCameraPolicy.safeZoom(30), 19);
    });

    test('replaces non-finite rotation and normalizes a valid heading', () {
      expect(RiderMapCameraPolicy.safeRotation(double.nan), 0);
      expect(RiderMapCameraPolicy.safeRotation(450), 90);
    });
  });
}
