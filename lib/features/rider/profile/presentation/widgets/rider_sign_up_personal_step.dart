import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/profile/presentation/styles/rider_sign_up_personal_step_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';
import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_document_tile.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_widgets.dart';
import 'package:agresell_app/features/shared/widgets/profile/phone_number_sync_control.dart';

part 'rider_sign_up_personal_fields.dart';

class RiderSignUpPersonalStep extends StatelessWidget {
  const RiderSignUpPersonalStep({required this.controller, super.key});
  final RiderSignUpController controller;

  @override
  Widget build(BuildContext context) {
    final draft = controller.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tell us who you are. Your profile picture is optional for now.',
          style: SharedPresentationStyles.mutedCaption,
        ),
        const SizedBox(height: 12),
        RiderSignUpDocumentTile(
          type: RiderDraftDocumentType.profilePhoto,
          document: draft.documents[RiderDraftDocumentType.profilePhoto],
          required: false,
          onPick: () => _pick(context, RiderDraftDocumentType.profilePhoto),
          onRemove: () =>
              controller.removeDocument(RiderDraftDocumentType.profilePhoto),
        ),
        _field(
          RiderSignUpFields.firstName,
          'First name',
          TextInputType.name,
          autofillHints: const [AutofillHints.givenName],
        ),
        _field(
          RiderSignUpFields.middleName,
          'Middle name (optional)',
          TextInputType.name,
        ),
        _field(
          RiderSignUpFields.lastName,
          'Last name',
          TextInputType.name,
          autofillHints: const [AutofillHints.familyName],
        ),
        _BirthDateField(controller: controller),
        _RiderGenderChoice(controller: controller),
        _RiderPhoneField(
          controller: controller,
          value: draft.value(RiderSignUpFields.mobile),
        ),
        RiderSignUpAvailabilityNote(
          state: controller.availabilityFor(RiderSignUpFields.mobile),
        ),
      ],
    );
  }

  Widget _field(
    String key,
    String label,
    TextInputType type, {
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: RiderSignUpTextField(
      label: label,
      value: controller.draft.value(key),
      error: controller.errorFor(key),
      keyboardType: type,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      onChanged: (value) => controller.updateValue(key, value),
    ),
  );

  Future<void> _pick(BuildContext context, RiderDraftDocumentType type) async {
    final source = await showRiderDocumentSourceSheet(context);
    if (source != null) await controller.addDocument(type, source);
  }
}

class _RiderGenderChoice extends StatelessWidget {
  const _RiderGenderChoice({required this.controller});

  final RiderSignUpController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.draft.value(RiderSignUpFields.gender);
    final error = controller.errorFor(RiderSignUpFields.gender);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gender', style: SharedPresentationStyles.captionSemibold),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _choice('Male', selected)),
              const SizedBox(width: 10),
              Expanded(child: _choice('Female', selected)),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(error, style: SharedPresentationStyles.errorCaption),
            ),
        ],
      ),
    );
  }

  Widget _choice(String value, String selected) {
    final isSelected = value == selected;
    return Semantics(
      button: true,
      selected: isSelected,
      label: value,
      child: InkWell(
        key: ValueKey('rider-gender-${value.toLowerCase()}'),
        onTap: () => controller.updateValue(RiderSignUpFields.gender, value),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 38,
          decoration: RiderSignUpPersonalStepStyles.animatedContainerDecoration(
            isSelected,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: AgrisellColors.authGreen,
                size: 17,
              ),
              const SizedBox(width: 6),
              Text(value, style: SharedPresentationStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}
