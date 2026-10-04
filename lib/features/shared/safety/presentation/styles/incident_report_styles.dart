import 'package:flutter/material.dart';
import '../../domain/safety_incident_category.dart';

abstract final class IncidentReportStyles {
  static const ink = Color(0xFF172F24);
  static const green = Color(0xFF138342);
  static const muted = Color(0xFF758184);
  static const sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  );
  static const title = TextStyle(
    color: ink,
    fontSize: 23,
    fontWeight: FontWeight.w800,
  );
  static const sectionTitle = TextStyle(
    color: Color(0xFF151A18),
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static const categoryTitle = TextStyle(
    color: Color(0xFF151A18),
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );
  static const description = TextStyle(color: muted, fontSize: 12, height: 1.4);
  static const inputText = TextStyle(color: ink, fontSize: 14, height: 1.5);
  static BoxDecoration category(bool selected) => BoxDecoration(
    color: selected ? const Color(0xFFF0F9F4) : Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: selected ? const Color(0xFF88CBA7) : const Color(0xFFE5E8E7),
    ),
  );
  static Color iconColor(SafetyIncidentCategory category) => switch (category) {
    SafetyIncidentCategory.harassment ||
    SafetyIncidentCategory.unsafePickup => green,
    SafetyIncidentCategory.suspiciousUser ||
    SafetyIncidentCategory.theft ||
    SafetyIncidentCategory.accident ||
    SafetyIncidentCategory.emergencySos => const Color(0xFFDE343E),
    SafetyIncidentCategory.fraudScam ||
    SafetyIncidentCategory.vehicleBreakdown ||
    SafetyIncidentCategory.roadClosure => const Color(0xFFE96A22),
    SafetyIncidentCategory.unsafeDestination => const Color(0xFF2E72F3),
    SafetyIncidentCategory.damagedGoods ||
    SafetyIncidentCategory.suspiciousProduct => const Color(0xFF942ED4),
    SafetyIncidentCategory.severeWeather => const Color(0xFFD8AB00),
    SafetyIncidentCategory.other => const Color(0xFF76817F),
  };
  static BoxDecoration iconBackground(SafetyIncidentCategory category) =>
      BoxDecoration(
        color: iconColor(category).withValues(alpha: 0.12),
        shape: BoxShape.circle,
      );
  static const radius = BorderRadius.all(Radius.circular(12));
  static final input = InputDecoration(
    hintText:
        'Provide details on what happened, where, and any immediate actions needed...',
    hintStyle: const TextStyle(color: muted, fontSize: 14, height: 1.5),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.all(14),
    counterText: '',
    border: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: Color(0xFFDEE3E1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: Color(0xFFDEE3E1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: green),
    ),
  );
  static final cancelButton = OutlinedButton.styleFrom(
    foregroundColor: green,
    side: const BorderSide(color: green),
    minimumSize: const Size(0, 50),
    maximumSize: Size.infinite,
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    shape: const RoundedRectangleBorder(borderRadius: radius),
  );
  static final submitButton = FilledButton.styleFrom(
    backgroundColor: green,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 50),
    maximumSize: Size.infinite,
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    shape: const RoundedRectangleBorder(borderRadius: radius),
  );
}
