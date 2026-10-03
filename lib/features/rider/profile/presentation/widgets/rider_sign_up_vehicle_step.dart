import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_widgets.dart';

class RiderSignUpVehicleStep extends StatelessWidget {
  const RiderSignUpVehicleStep({required this.controller, super.key});
  final RiderSignUpController controller;

  @override
  Widget build(BuildContext context) {
    final vehicle = _vehicle(controller.draft);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add the vehicle type and plate number shown in the final ERD.',
          style: SharedPresentationStyles.mutedCaption,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<RiderVehicleType>(
          isExpanded: true,
          dropdownColor: AppDropdownStyle.menuColor,
          borderRadius: AppDropdownStyle.menuBorderRadius,
          style: AppDropdownStyle.textStyle,
          iconEnabledColor: AppDropdownStyle.iconColor,
          initialValue: vehicle,
          decoration: AuthInputStyle.decoration(
            label: 'Vehicle type',
            contentPadding: riderSignUpSelectionContentPadding,
            errorText: controller.errorFor(RiderSignUpFields.vehicleType),
          ),
          items: [
            for (final item in RiderVehicleType.values)
              DropdownMenuItem(value: item, child: Text(item.label)),
          ],
          onChanged: (value) => controller.updateValue(
            RiderSignUpFields.vehicleType,
            value?.name ?? '',
          ),
        ),
        if (vehicle?.requiresPlate ?? false) ...[
          const SizedBox(height: 10),
          RiderSignUpTextField(
            label: 'Vehicle plate number',
            value: controller.draft.value(RiderSignUpFields.plate),
            error: controller.errorFor(RiderSignUpFields.plate),
            onChanged: (value) =>
                controller.updateValue(RiderSignUpFields.plate, value),
          ),
        ],
      ],
    );
  }

  RiderVehicleType? _vehicle(RiderSignUpDraft draft) => RiderVehicleType.values
      .where((item) => item.name == draft.value(RiderSignUpFields.vehicleType))
      .firstOrNull;
}
