import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';

import '../controllers/farmer_information_request_form_controller.dart';
import '../styles/farmer_information_request_styles.dart';
import '../styles/farmer_verification_form_styles.dart';
import 'farmer_verification_text_field.dart';
import 'farmer_verification_upload_card.dart';

class FarmerVerificationCorrectionForm extends StatelessWidget {
  const FarmerVerificationCorrectionForm({
    required this.details,
    required this.form,
    required this.profileImageBytes,
    required this.farmImageBytes,
    required this.onPickProfile,
    required this.onPickFarm,
    super.key,
  });

  final FarmerVerificationDetails details;
  final FarmerInformationRequestFormController form;
  final Uint8List? profileImageBytes;
  final Uint8List? farmImageBytes;
  final VoidCallback onPickProfile;
  final VoidCallback onPickFarm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: FarmerVerificationFormStyles.formPanel,
      padding: FarmerInformationRequestStyles.formPadding,
      child: Column(
        crossAxisAlignment: FarmerInformationRequestStyles.alignStart,
        children: [
          const Text(
            'Update Profile & Documents',
            style: FarmerInformationRequestStyles.formTitle,
          ),
          const SizedBox(height: FarmerInformationRequestStyles.smallGap),
          const Text(
            'Correct any flagged information or re-upload clear photos/documents below.',
            style: FarmerInformationRequestStyles.subtitle,
          ),
          const SizedBox(height: FarmerInformationRequestStyles.formHeaderGap),
          FarmerVerificationTextField(
            controller: form.firstName,
            label: 'First Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: FarmerInformationRequestStyles.fieldGap),
          FarmerVerificationTextField(
            controller: form.lastName,
            label: 'Last Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: FarmerInformationRequestStyles.fieldGap),
          FarmerVerificationTextField(
            controller: form.phone,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: FarmerInformationRequestStyles.fieldGap),
          FarmerVerificationTextField(
            controller: form.farmName,
            label: 'Farm Name',
            icon: Icons.agriculture_rounded,
          ),
          const SizedBox(height: FarmerInformationRequestStyles.fieldGap),
          FarmerVerificationTextField(
            controller: form.farmAddress,
            label: 'Farm Address / Location',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: FarmerInformationRequestStyles.formHeaderGap),
          const Divider(),
          const SizedBox(height: FarmerInformationRequestStyles.fieldGap),
          const Text(
            'Verification Photos & Documents',
            style: FarmerInformationRequestStyles.sectionTitle,
          ),
          const SizedBox(height: FarmerInformationRequestStyles.sectionGap),
          Row(
            children: [
              Expanded(
                child: FarmerVerificationUploadCard(
                  title: 'Profile Photo',
                  hasImage:
                      profileImageBytes != null ||
                      (details.profileImageUrl?.isNotEmpty == true),
                  imageBytes: profileImageBytes,
                  onPick: onPickProfile,
                ),
              ),
              const SizedBox(width: FarmerInformationRequestStyles.sectionGap),
              Expanded(
                child: FarmerVerificationUploadCard(
                  title: 'Farm / Certificate',
                  hasImage:
                      farmImageBytes != null || details.farmImages.isNotEmpty,
                  imageBytes: farmImageBytes,
                  onPick: onPickFarm,
                ),
              ),
            ],
          ),
          const SizedBox(height: FarmerInformationRequestStyles.formHeaderGap),
          const Divider(),
          const SizedBox(height: FarmerInformationRequestStyles.fieldGap),
          const Text(
            'Note to Reviewer',
            style: FarmerInformationRequestStyles.sectionTitle,
          ),
          const SizedBox(height: FarmerInformationRequestStyles.labelGap),
          TextField(
            controller: form.notes,
            maxLines: FarmerInformationRequestStyles.notesLines,
            decoration: FarmerVerificationFormStyles.notesInput,
          ),
        ],
      ),
    );
  }
}
