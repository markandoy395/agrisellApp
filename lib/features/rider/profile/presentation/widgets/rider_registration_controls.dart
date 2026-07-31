import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

enum RiderUploadKind { profilePhoto, validId, driverLicense, vehiclePhoto }

extension RiderUploadKindDetails on RiderUploadKind {
  String get label => switch (this) {
    RiderUploadKind.profilePhoto => 'Profile photo',
    RiderUploadKind.validId => 'Valid ID',
    RiderUploadKind.driverLicense => "Driver's license",
    RiderUploadKind.vehiclePhoto => 'Vehicle photo',
  };

  IconData get icon => switch (this) {
    RiderUploadKind.profilePhoto => Icons.account_circle_outlined,
    RiderUploadKind.validId => Icons.badge_outlined,
    RiderUploadKind.driverLicense => Icons.credit_card_outlined,
    RiderUploadKind.vehiclePhoto => Icons.directions_car_outlined,
  };
}

class RiderRegistrationSectionTitle extends StatelessWidget {
  const RiderRegistrationSectionTitle({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AgrisellColors.headingGreen,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        description,
        style: const TextStyle(
          color: AgrisellColors.mutedText,
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

class RiderUploadTile extends StatelessWidget {
  const RiderUploadTile({
    required this.kind,
    required this.hasUpload,
    required this.onTap,
    this.required = true,
    super.key,
  });

  final RiderUploadKind kind;
  final bool hasUpload;
  final bool required;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = hasUpload
        ? AgrisellColors.statusGreenText
        : AgrisellColors.authGreen;
    return Semantics(
      button: true,
      label: 'Upload ${kind.label}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasUpload
                ? AgrisellColors.statusGreenBackground
                : AgrisellColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.32)),
          ),
          child: Row(
            children: [
              Icon(
                hasUpload ? Icons.check_circle_rounded : kind.icon,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasUpload
                      ? '${kind.label} selected'
                      : 'Upload ${kind.label}${required ? '' : ' (optional)'}',
                  style: TextStyle(
                    color: AgrisellColors.brandBlack,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.upload_file_outlined, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
