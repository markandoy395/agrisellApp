import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/presentation/location_selector.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_registration_location.dart';

Future<RiderRegistrationLocation?> showRiderSignUpLocationPicker(
  BuildContext context, {
  double? latitude,
  double? longitude,
  String? address,
}) async {
  final selected = await showLocationSelector(
    context,
    role: LocationOwnerRole.rider,
    initialAddress: address,
    initialLatitude: latitude,
    initialLongitude: longitude,
  );
  return selected == null
      ? null
      : RiderRegistrationLocation.fromConfirmed(selected);
}
