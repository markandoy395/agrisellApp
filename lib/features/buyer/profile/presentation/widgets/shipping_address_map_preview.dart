import 'package:flutter/material.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/location_map_preview.dart';

class ShippingAddressMapPreview extends StatelessWidget {
  const ShippingAddressMapPreview({
    required this.latitude,
    required this.longitude,
    required this.onTap,
    super.key,
  });

  final double? latitude;
  final double? longitude;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => LocationMapPreview(
    latitude: latitude,
    longitude: longitude,
    onTap: onTap,
    emptyLabel: 'Tap to select the delivery pin',
    selectedLabel: 'Tap to adjust the delivery pin',
  );
}
