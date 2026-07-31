import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_logistics_company_selector.dart';

class RiderSignUpReviewStep extends StatelessWidget {
  const RiderSignUpReviewStep({required this.controller, super.key});
  final RiderSignUpController controller;

  @override
  Widget build(BuildContext context) {
    final draft = controller.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review each section before you submit your Rider application.',
          style: TextStyle(fontSize: 12, color: AgrisellColors.mutedText),
        ),
        const SizedBox(height: 12),
        _ReviewCard(
          title: 'Personal information',
          values: [
            '${draft.value(RiderSignUpFields.firstName)} ${draft.value(RiderSignUpFields.lastName)}',
            draft.value(RiderSignUpFields.mobile),
            draft.value(RiderSignUpFields.email),
          ],
          onEdit: () => controller.editStep(RiderSignUpStep.personal),
        ),
        _ReviewCard(
          title: 'GPS location',
          values: [
            draft.value(RiderSignUpFields.location),
            '${draft.value(RiderSignUpFields.latitude)}, '
                '${draft.value(RiderSignUpFields.longitude)}',
          ],
          onEdit: () => controller.editStep(RiderSignUpStep.address),
        ),
        _ReviewCard(
          title: 'Vehicle information',
          values: [
            draft.value(RiderSignUpFields.vehicleType),
            draft.value(RiderSignUpFields.plate).isEmpty
                ? 'No plate required'
                : draft.value(RiderSignUpFields.plate),
          ],
          onEdit: () => controller.editStep(RiderSignUpStep.vehicle),
        ),
        _ReviewCard(
          title: 'Driver information',
          values: [
            controller.licenseNumber.isEmpty
                ? 'No license required'
                : controller.licenseNumber,
          ],
          onEdit: () => controller.editStep(RiderSignUpStep.documents),
        ),
        const Text(
          'Logistics partner',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        RiderLogisticsCompanySelector(controller: controller),
        const SizedBox(height: 12),
        _ReviewCard(
          title: 'Account information',
          values: [
            draft.value(RiderSignUpFields.email),
            'Password secured for submission',
          ],
          onEdit: () => controller.editStep(RiderSignUpStep.security),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: draft.acceptsTerms,
          onChanged: (value) =>
              controller.updateAgreement(terms: value ?? false),
          title: const Text(
            'I accept the Terms and Conditions',
            style: TextStyle(fontSize: 12),
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: draft.acceptsPrivacy,
          onChanged: (value) =>
              controller.updateAgreement(privacy: value ?? false),
          title: const Text(
            'I accept the Privacy Policy',
            style: TextStyle(fontSize: 12),
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: draft.confirmsAccuracy,
          onChanged: (value) =>
              controller.updateAgreement(accuracy: value ?? false),
          title: const Text(
            'I confirm that my submitted information is accurate',
            style: TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your Rider account will be reviewed after submission. You will receive a notification when your account is approved.',
          style: TextStyle(fontSize: 12, color: AgrisellColors.mutedText),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.values,
    required this.onEdit,
  });
  final String title;
  final List<String> values;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AgrisellColors.fieldFill,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AgrisellColors.borderLine),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(onPressed: onEdit, child: const Text('Edit')),
          ],
        ),
        for (final value in values)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    ),
  );
}
