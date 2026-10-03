import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/map_coordinates.dart';
import 'package:agresell_app/core/utils/written_address.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/buyer/cart/presentation/styles/checkout_screen_styles.dart';
import 'package:agresell_app/features/shared/location/data/confirmed_location_repository.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/presentation/location_selector.dart';

class CheckoutDeliveryLocationCoordinator {
  const CheckoutDeliveryLocationCoordinator({
    required this.repository,
    required this.profile,
    this.initialDeliveryAddress,
  });

  final ConfirmedLocationRepository repository;
  final UserProfile profile;
  final String? initialDeliveryAddress;

  ConfirmedLocation? profileDeliveryLocation() {
    if (!MapCoordinates.isValid(
      latitude: profile.shippingLatitude,
      longitude: profile.shippingLongitude,
    )) {
      return null;
    }
    return ConfirmedLocation(
      latitude: profile.shippingLatitude!,
      longitude: profile.shippingLongitude!,
      accuracyMeters: 0,
      capturedAt: DateTime.now(),
      address: WrittenAddress.valueOrNull(profile.address),
    );
  }

  Future<ConfirmedLocation?> restoreLocation() async {
    final saved = await repository.load(LocationOwnerRole.buyer);
    final location = saved ?? profileDeliveryLocation();
    if (location != null && saved == null) {
      unawaited(repository.confirm(LocationOwnerRole.buyer, location));
    }
    return location;
  }

  String get defaultDeliveryAddress {
    final initial = initialDeliveryAddress?.trim() ?? '';
    return WrittenAddress.valueOrNull(initial) ??
        WrittenAddress.valueOrNull(profile.address) ??
        '';
  }

  String resolveDisplayAddress(ConfirmedLocation? location) {
    return WrittenAddress.valueOrNull(location?.address) ??
        (defaultDeliveryAddress.isEmpty
            ? CheckoutScreenStyles.selectDeliveryLocationHint
            : defaultDeliveryAddress);
  }

  Future<ConfirmedLocation?> selectLocation(
    BuildContext context, {
    ConfirmedLocation? currentLocation,
  }) async {
    final location = await showLocationSelector(
      context,
      role: LocationOwnerRole.buyer,
      initialAddress: currentLocation?.address ?? defaultDeliveryAddress,
      repository: repository,
    );
    if (location != null && context.mounted) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        CheckoutScreenStyles.snackBar(
          CheckoutScreenStyles.deliveryLocationConfirmed,
        ),
      );
    }
    return location;
  }
}
