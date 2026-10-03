import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../styles/farmer_information_request_styles.dart';
import '../styles/farmer_verification_form_styles.dart';

class FarmerVerificationUploadCard extends StatelessWidget {
  const FarmerVerificationUploadCard({
    required this.title,
    required this.hasImage,
    required this.imageBytes,
    required this.onPick,
    super.key,
  });

  final String title;
  final bool hasImage;
  final Uint8List? imageBytes;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: FarmerInformationRequestStyles.uploadRadius,
      child: Container(
        padding: FarmerInformationRequestStyles.uploadPadding,
        decoration: hasImage
            ? FarmerVerificationFormStyles.existingUpload
            : FarmerVerificationFormStyles.emptyUpload,
        child: Column(
          children: [
            if (imageBytes != null)
              ClipRRect(
                borderRadius: FarmerInformationRequestStyles.previewRadius,
                child: Image.memory(
                  imageBytes!,
                  height: FarmerInformationRequestStyles.uploadImageHeight,
                  width: FarmerInformationRequestStyles.fullWidth,
                  fit: FarmerInformationRequestStyles.uploadImageFit,
                ),
              )
            else
              Icon(
                hasImage
                    ? Icons.check_circle_outline_rounded
                    : Icons.cloud_upload_outlined,
                size: FarmerInformationRequestStyles.uploadIconSize,
                color: hasImage
                    ? FarmerVerificationFormStyles.existingImageColor
                    : FarmerVerificationFormStyles.missingImageColor,
              ),
            const SizedBox(height: FarmerInformationRequestStyles.inlineGap),
            Text(
              title,
              textAlign: FarmerInformationRequestStyles.centeredText,
              style: FarmerInformationRequestStyles.uploadTitle,
            ),
            const SizedBox(height: FarmerInformationRequestStyles.smallGap),
            Text(
              hasImage ? 'Tap to change' : 'Tap to upload',
              style: FarmerInformationRequestStyles.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}
