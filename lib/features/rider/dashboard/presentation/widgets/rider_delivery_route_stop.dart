import 'package:flutter/material.dart';
import '../styles/rider_reference_styles.dart';

class RiderDeliveryRouteStop extends StatelessWidget {
  const RiderDeliveryRouteStop({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final pickup = label == 'Pickup';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 58,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              if (pickup)
                const Positioned(
                  top: 14,
                  bottom: 0,
                  child: SizedBox(
                    width: 2,
                    child: ColoredBox(color: RiderReferenceStyles.green),
                  ),
                ),
              Container(
                width: 19,
                height: 19,
                decoration: RiderReferenceStyles.stop(pickup),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: RiderReferenceStyles.value),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: RiderReferenceStyles.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
