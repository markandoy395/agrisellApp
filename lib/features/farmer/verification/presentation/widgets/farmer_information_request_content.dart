import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';

import '../controllers/farmer_information_request_form_controller.dart';
import '../styles/farmer_information_request_styles.dart';
import 'farmer_verification_correction_form.dart';
import 'farmer_verification_feedback_card.dart';

class FarmerInformationRequestContent extends StatelessWidget {
  const FarmerInformationRequestContent({
    required this.details,
    required this.form,
    required this.profileImageBytes,
    required this.farmImageBytes,
    required this.isSubmitting,
    required this.onPickProfile,
    required this.onPickFarm,
    required this.onSubmit,
    super.key,
  });

  final FarmerVerificationDetails details;
  final FarmerInformationRequestFormController form;
  final Uint8List? profileImageBytes;
  final Uint8List? farmImageBytes;
  final bool isSubmitting;
  final VoidCallback onPickProfile;
  final VoidCallback onPickFarm;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FarmerInformationRequestStyles.background,
      appBar: AppBar(
        backgroundColor: FarmerInformationRequestStyles.green,
        foregroundColor: FarmerInformationRequestStyles.white,
        elevation: FarmerInformationRequestStyles.flatElevation,
        title: const Text(
          'Information Requested',
          style: FarmerInformationRequestStyles.title,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: FarmerInformationRequestStyles.contentPadding,
          child: Column(
            crossAxisAlignment: FarmerInformationRequestStyles.alignStart,
            children: [
              FarmerVerificationFeedbackCard(details: details),
              const SizedBox(
                height: FarmerInformationRequestStyles.feedbackGap,
              ),
              FarmerVerificationCorrectionForm(
                details: details,
                form: form,
                profileImageBytes: profileImageBytes,
                farmImageBytes: farmImageBytes,
                onPickProfile: onPickProfile,
                onPickFarm: onPickFarm,
              ),
              const SizedBox(height: FarmerInformationRequestStyles.submitGap),
              SizedBox(
                width: FarmerInformationRequestStyles.fullWidth,
                height: FarmerInformationRequestStyles.submitHeight,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  style: FarmerInformationRequestStyles.submitButton,
                  child: isSubmitting
                      ? const SizedBox(
                          width: FarmerInformationRequestStyles.spinnerSize,
                          height: FarmerInformationRequestStyles.spinnerSize,
                          child: CircularProgressIndicator(
                            color: FarmerInformationRequestStyles.white,
                            strokeWidth: FarmerInformationRequestStyles
                                .spinnerStrokeWidth,
                          ),
                        )
                      : const Text(
                          'Submit Corrections',
                          style: FarmerInformationRequestStyles.title,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
