import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_details.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderRequestDetailSections extends StatelessWidget {
  const RiderRequestDetailSections({required this.request, super.key});
  final DeliveryRequest request;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _section('Product information', [
        _line(Icons.inventory_2_outlined, request.productName),
        if (request.productCategory.isNotEmpty)
          _line(Icons.category_outlined, request.productCategory),
        if (request.quantityDescription.isNotEmpty)
          _line(Icons.scale_outlined, request.quantityDescription),
        if (request.totalWeightKg != null)
          _line(
            Icons.fitness_center_outlined,
            '${request.totalWeightKg!.toStringAsFixed(1)} kg total weight',
          ),
        if (request.packageDimensions != null)
          _line(Icons.straighten_outlined, request.packageDimensions!.label),
        if (request.productDescription.isNotEmpty)
          _line(Icons.notes_outlined, request.productDescription),
        if (request.handlingRequirements.isNotEmpty)
          _line(
            Icons.warning_amber_rounded,
            request.handlingRequirements
                .map((item) => item.type.label)
                .join(' • '),
          ),
      ]),
      const SizedBox(height: 10),
      _section('Pickup information', [
        _line(Icons.storefront_outlined, 'Seller: ${request.sellerName}'),
        _line(Icons.place_outlined, request.pickupLocation.address),
        _line(
          Icons.event_outlined,
          'Pickup deadline: ${_date(context, request.pickupDeadline)}',
        ),
        _line(
          Icons.route_outlined,
          request.routeDistanceKm == null
              ? 'Pickup route unavailable — retry later'
              : '${request.routeDistanceKm!.toStringAsFixed(1)} km • '
                    '${request.routeEstimatedTravelMinutes} min to pickup',
        ),
        if (request.pickupInstructions.isNotEmpty)
          _line(Icons.info_outline, request.pickupInstructions),
      ]),
      const SizedBox(height: 10),
      _section('Delivery information', [
        _line(Icons.person_outline_rounded, 'Buyer destination'),
        _line(Icons.location_on_outlined, request.deliveryLocation.address),
        if (request.deliveryDeadline != null)
          _line(
            Icons.event_available_outlined,
            'Delivery deadline: ${_date(context, request.deliveryDeadline!)}',
          ),
        _line(
          Icons.route_rounded,
          request.pickupToDeliveryDistanceKm == null
              ? 'Delivery route unavailable — retry later'
              : '${request.pickupToDeliveryDistanceKm!.toStringAsFixed(1)} km • '
                    '${request.pickupToDeliveryMinutes} min after pickup',
        ),
        if (request.totalTripMinutes != null)
          _line(
            Icons.timelapse_rounded,
            '${request.totalTripMinutes} min estimated total trip',
          ),
        if (request.deliveryInstructions.isNotEmpty)
          _line(Icons.info_outline, request.deliveryInstructions),
      ]),
      const SizedBox(height: 10),
      _section('Estimated Rider earning', _earningLines(request)),
      const SizedBox(height: 10),
      _section('Vehicle and handling requirements', [
        _line(
          Icons.local_shipping_outlined,
          request.requiredVehicleTypes.isEmpty
              ? 'No specific vehicle returned by backend'
              : request.requiredVehicleTypes
                    .map((item) => item.label)
                    .join(', '),
        ),
        if (request.requiredCapacityKg != null)
          _line(
            Icons.scale_outlined,
            '${request.requiredCapacityKg!.toStringAsFixed(1)} kg capacity required',
          ),
        _line(
          Icons.verified_outlined,
          'Compatible at the latest authoritative eligibility check',
        ),
      ]),
      const SizedBox(height: 10),
      _section('Other information', [
        if (request.paymentMethod.isNotEmpty)
          _line(Icons.account_balance_wallet_outlined, request.paymentMethod),
        if (request.cashOnDelivery case final cash?) ...[
          _line(
            Icons.payments_outlined,
            '${cash.currencyCode} ${cash.amountToCollect.toStringAsFixed(2)} to collect',
          ),
          _line(
            Icons.receipt_long_outlined,
            cash.remittanceRequired
                ? 'Cash remittance is required'
                : 'No Rider remittance required',
          ),
          if (cash.riderCashResponsibility.isNotEmpty)
            _line(Icons.shield_outlined, cash.riderCashResponsibility),
        ],
        _line(Icons.priority_high_rounded, request.priority.name),
        if (request.expiresAt != null)
          _line(
            Icons.timer_outlined,
            'Request expires: ${_date(context, request.expiresAt!)}',
          ),
        if (request.cancellationConditions.isNotEmpty)
          _line(Icons.policy_outlined, request.cancellationConditions),
      ]),
    ],
  );

  List<Widget> _earningLines(DeliveryRequest request) {
    final fee = request.feeBreakdown;
    if (fee == null) {
      return [_line(Icons.payments_outlined, 'Fee estimate unavailable')];
    }
    return [
      _line(
        Icons.payments_outlined,
        'PHP ${request.deliveryFee.toStringAsFixed(2)} estimated total',
      ),
      for (final component in fee.components)
        _line(
          Icons.receipt_long_outlined,
          '${component.label}: ${component.amount < 0 ? '-' : ''}'
          '${fee.currencyCode} ${component.amount.abs().toStringAsFixed(2)}',
        ),
    ];
  }

  Widget _section(String title, List<Widget> children) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 9),
        ...children,
      ],
    ),
  );

  Widget _line(IconData icon, String text) =>
      RiderRequestDetailLine(icon: icon, text: text);

  String _date(BuildContext context, DateTime value) {
    final local = value.toLocal();
    final material = MaterialLocalizations.of(context);
    return '${material.formatShortDate(local)} '
        '${material.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
  }
}
