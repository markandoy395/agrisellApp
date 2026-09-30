import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';

const _green = Color(0xFF116F43);
const _mint = Color(0xFFE8F6EF);
const _ink = Color(0xFF10252C);
const _muted = Color(0xFF6B7A80);

Future<bool> showFarmerRiderConfirmationDialog(
  BuildContext context, {
  required FarmerRiderCandidate rider,
  required FarmerRiderDeliveryDetails delivery,
}) async =>
    await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF123D2E).withValues(alpha: 0.3),
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        constraints: const BoxConstraints(maxWidth: 460),
        scrollable: true,
        titlePadding: const EdgeInsets.fromLTRB(22, 22, 12, 0),
        contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
        actionsPadding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _mint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delivery_dining_rounded,
                      color: _green,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Confirm rider request',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Review your delivery details before sending.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Close confirmation',
              onPressed: () => Navigator.of(context).pop(false),
              icon: const Icon(Icons.close_rounded, color: _muted, size: 22),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: _green,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'YOUR RIDER',
                            style: TextStyle(
                              color: _green,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            rider.name,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _detail(Icons.receipt_long_outlined, 'Order', delivery.orderId),
              _detail(
                Icons.inventory_2_outlined,
                'Goods',
                delivery.goodsSummary,
              ),
              const Divider(height: 22, color: Color(0xFFE6ECE9)),
              _detail(
                Icons.trip_origin_rounded,
                'Pickup',
                delivery.pickupAddress,
              ),
              _detail(
                Icons.location_on_outlined,
                'Destination',
                delivery.destination,
              ),
              if (delivery.routeDistanceKm != null)
                Padding(
                  padding: const EdgeInsets.only(left: 34, bottom: 12),
                  child: Text(
                    '${delivery.routeDistanceKm!.toStringAsFixed(1)} km pickup to buyer',
                    style: const TextStyle(
                      color: _green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              _detail(
                Icons.calendar_month_outlined,
                'Schedule',
                MaterialLocalizations.of(
                  context,
                ).formatFullDate(delivery.requestedSchedule),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE4ECE7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Proposed fee',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      rider.proposedDeliveryFee == null
                          ? 'To be confirmed'
                          : 'PHP ${rider.proposedDeliveryFee!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: _green,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: rider.isOfflineManualCandidate
                      ? const Color(0xFFFFF6E7)
                      : _mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      rider.isOfflineManualCandidate
                          ? Icons.schedule_rounded
                          : Icons.info_outline_rounded,
                      color: rider.isOfflineManualCandidate
                          ? const Color(0xFF997025)
                          : _green,
                      size: 20,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        rider.isOfflineManualCandidate
                            ? 'This rider is offline. The booking expires in $offlineRiderBookingMinutes minutes unless the rider accepts.'
                            : 'The rider must accept before this order is assigned.',
                        style: TextStyle(
                          color: rider.isOfflineManualCandidate
                              ? const Color(0xFF805F27)
                              : _green,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
            Builder(
              builder: (context) {
              final back = OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _green,
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: _green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
              final send = FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send request',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
                if (MediaQuery.sizeOf(context).width < 336 ||
                  MediaQuery.textScalerOf(context).scale(14) > 19) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [send, const SizedBox(height: 8), back],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 2, child: back),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: send),
                ],
              );
            },
          ),
        ],
      ),
    ) ??
    false;

Widget _detail(IconData icon, String label, String value) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: _green, size: 21),
      const SizedBox(width: 13),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
