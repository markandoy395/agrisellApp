import 'package:agresell_app/features/farmer/verification/presentation/styles/farmer_information_request_banner_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';

class FarmerInformationRequestBanner extends StatelessWidget {
  const FarmerInformationRequestBanner({
    required this.details,
    required this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    super.key,
  });

  final FarmerVerificationDetails details;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    if (!details.isNeedsInformation) return const SizedBox.shrink();

    final message = details.hasMessage
        ? details.message!
        : 'The admin reviewed your profile and requested additional or corrected verification information.';

    return Padding(
      padding: margin,
      child: Container(
        decoration: FarmerInformationRequestBannerStyles.containerDecoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: FarmerInformationRequestBannerStyles
                            .containerDecoration2,
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFE65100),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Action Required: Information Requested',
                              style: FarmerInformationRequestBannerStyles
                                  .actionRequiredInformationRequestedText,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: FarmerInformationRequestBannerStyles
                                  .messageText,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (details.hasMissingItems) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: details.missingItems
                          .map((item) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: FarmerInformationRequestBannerStyles
                                  .containerDecoration3,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 12,
                                    color: Color(0xFFE65100),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item,
                                    style: FarmerInformationRequestBannerStyles
                                        .itemText,
                                  ),
                                ],
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        'Requested: ${details.formattedRequestedDate}',
                        style: FarmerInformationRequestBannerStyles.textStyle,
                      ),
                      ElevatedButton.icon(
                        onPressed: onTap,
                        style: FarmerInformationRequestBannerStyles
                            .elevatedButtonStyle,
                        icon: const Icon(Icons.edit_note_rounded, size: 16),
                        label: const Text(
                          'Review & Resubmit',
                          style: SharedPresentationStyles.captionBold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
