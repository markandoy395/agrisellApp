import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';

abstract final class DeliveryLiveMapStyles {
  static final mapRadius = BorderRadius.circular(16);
  static const cameraPadding = EdgeInsets.all(48);
  static final routeColor = AgrisellColors.authGreen.withValues(alpha: 0.85);
  static const warningColor = Color(0xFF856404);
  static const staleColor = Color(0xFFD97706);
  static const warningPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static final warningDecoration = BoxDecoration(
    color: const Color(0xFFFFF3CD),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: const Color(0xFFFFEEBA)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
  static const warningText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: warningColor,
  );
  static const detailsPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static final detailsDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.95),
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
  static final _gpsLabels = {
    for (final state in DeliveryGpsState.values)
      state: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: switch (state) {
          DeliveryGpsState.recent => AgrisellColors.authGreen,
          DeliveryGpsState.stale => staleColor,
          _ => AgrisellColors.mutedText,
        },
      ),
  };
  static TextStyle gpsLabel(DeliveryGpsState state) => _gpsLabels[state]!;
  static final _gpsDots = {
    for (final state in DeliveryGpsState.values) state: _dotDecoration(state),
  };
  static BoxDecoration gpsDot(DeliveryGpsState state) => _gpsDots[state]!;
  static BoxDecoration _dotDecoration(DeliveryGpsState state) {
    final color = switch (state) {
      DeliveryGpsState.recent => AgrisellColors.authGreen,
      DeliveryGpsState.stale => staleColor,
      _ => Colors.grey.shade500,
    };
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        if (state.isLive)
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
      ],
    );
  }

  static const speedPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 3);
  static final speedDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(6),
  );
  static const speedText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.authGreen,
  );
  static const arrivalText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.brandBlack,
  );
  static const distanceText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.mutedText,
  );

  static final actionRadius = BorderRadius.circular(10);
  static Color actionBackground(bool active) =>
      active ? AgrisellColors.authGreen : Colors.white;
  static Color actionIcon(bool active) =>
      active ? Colors.white : AgrisellColors.brandBlack;

  static final pickupDecoration = _stopDecoration(const Color(0xFF2563EB));
  static final destinationDecoration = _stopDecoration(const Color(0xFFDC2626));
  static BoxDecoration _stopDecoration(Color color) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
    border: Border.all(color: Colors.white, width: 2.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  );
  static const stopText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w900,
    fontSize: 15,
  );
  static final riderHalo = BoxDecoration(
    shape: BoxShape.circle,
    color: AgrisellColors.authGreen.withValues(alpha: 0.2),
  );
  static final liveRiderDecoration = _riderDecoration(AgrisellColors.authGreen);
  static final inactiveRiderDecoration = _riderDecoration(Colors.grey.shade600);
  static BoxDecoration riderDecoration(bool live) =>
      live ? liveRiderDecoration : inactiveRiderDecoration;
  static BoxDecoration _riderDecoration(Color color) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
    border: Border.all(color: Colors.white, width: 2.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.25),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
