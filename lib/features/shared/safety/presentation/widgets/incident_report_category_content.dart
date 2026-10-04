import 'package:flutter/material.dart';
import '../../domain/safety_incident_category.dart';

String incidentCategoryDescription(
  SafetyIncidentCategory category,
) => switch (category) {
  SafetyIncidentCategory.harassment =>
    'Threatening behavior, harassment, or feeling unsafe.',
  SafetyIncidentCategory.suspiciousUser => 'Fake accounts or impersonation.',
  SafetyIncidentCategory.fraudScam =>
    'Scams, fraudulent activities, or payment-related issues.',
  SafetyIncidentCategory.unsafeDestination =>
    'Unsafe or risky delivery location.',
  SafetyIncidentCategory.damagedGoods =>
    'Damaged items or hazardous materials.',
  SafetyIncidentCategory.severeWeather => 'Weather-related incidents or flood.',
  SafetyIncidentCategory.other => 'Any other safety-related concern.',
  SafetyIncidentCategory.accident =>
    'Traffic accidents, injuries, or collisions.',
  SafetyIncidentCategory.vehicleBreakdown =>
    'Vehicle problems that affect safe travel.',
  SafetyIncidentCategory.roadClosure =>
    'Blocked roads or unsafe travel routes.',
  SafetyIncidentCategory.theft => 'Stolen goods, theft, or robbery.',
  SafetyIncidentCategory.unsafePickup => 'Unsafe or risky pickup location.',
  SafetyIncidentCategory.suspiciousProduct =>
    'Potentially contaminated or unsafe products.',
  SafetyIncidentCategory.emergencySos =>
    'An emergency requiring immediate assistance.',
};

IconData incidentCategoryIcon(SafetyIncidentCategory category) =>
    switch (category) {
      SafetyIncidentCategory.harassment => Icons.shield_outlined,
      SafetyIncidentCategory.suspiciousUser => Icons.person_off_outlined,
      SafetyIncidentCategory.fraudScam => Icons.credit_card_rounded,
      SafetyIncidentCategory.unsafeDestination ||
      SafetyIncidentCategory.unsafePickup => Icons.location_on_rounded,
      SafetyIncidentCategory.damagedGoods ||
      SafetyIncidentCategory.suspiciousProduct => Icons.inventory_2_outlined,
      SafetyIncidentCategory.severeWeather => Icons.thunderstorm_rounded,
      SafetyIncidentCategory.other => Icons.more_horiz_rounded,
      SafetyIncidentCategory.accident => Icons.car_crash_outlined,
      SafetyIncidentCategory.vehicleBreakdown => Icons.car_repair_rounded,
      SafetyIncidentCategory.roadClosure => Icons.block_rounded,
      SafetyIncidentCategory.theft => Icons.lock_outline_rounded,
      SafetyIncidentCategory.emergencySos => Icons.sos_rounded,
    };
