import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/location/data/confirmed_location_repository.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/presentation/controllers/gps_selection_controller.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/location_selector_sheet.dart';

Future<ConfirmedLocation?> showLocationSelector(
  BuildContext context, {
  required LocationOwnerRole role,
  String? initialAddress,
  double? initialLatitude,
  double? initialLongitude,
  bool showAddressFields = true,
  ConfirmedLocationRepository? repository,
  GpsSelectionController? gpsController,
}) => showModalBottomSheet<ConfirmedLocation>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  clipBehavior: Clip.none,
  builder: (context) => AnimatedPadding(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOut,
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: LocationSelectorSheet(
      role: role,
      initialAddress: initialAddress,
      initialLatitude: initialLatitude,
      initialLongitude: initialLongitude,
      showAddressFields: showAddressFields,
      repository: repository,
      gpsController: gpsController,
    ),
  ),
);
