import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/utils/written_address.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/presentation/location_selector.dart';

class ProfileLocationPickerButton extends StatelessWidget {
  const ProfileLocationPickerButton({
    required this.role,
    required this.addressController,
    super.key,
  });

  const ProfileLocationPickerButton.buyer(this.addressController, {super.key})
    : role = LocationOwnerRole.buyer;

  const ProfileLocationPickerButton.farmer(this.addressController, {super.key})
    : role = LocationOwnerRole.farmer;

  final LocationOwnerRole role;
  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Choose exact GPS location',
    visualDensity: VisualDensity.compact,
    color: AgrisellColors.authGreen,
    icon: const Icon(Icons.add_location_alt_outlined, size: 18),
    onPressed: () async {
      final location = await showLocationSelector(
        context,
        role: role,
        initialAddress: addressController.text,
      );
      if (location == null || !context.mounted) return;
      final address = WrittenAddress.valueOrNull(location.address);
      if (address == null) return;
      addressController.text = address;
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('Location successfully confirmed.')),
      );
    },
  );
}
