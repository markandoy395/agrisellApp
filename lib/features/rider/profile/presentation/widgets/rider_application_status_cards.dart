import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class RiderApplicationReferenceCard extends StatelessWidget {
  const RiderApplicationReferenceCard({required this.reference, super.key});
  final String reference;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AgrisellColors.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AgrisellColors.borderLine),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'APPLICATION REFERENCE',
          style: TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        SelectableText(
          reference,
          style: const TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class RiderApplicationStatusCard extends StatelessWidget {
  const RiderApplicationStatusCard({required this.isPending, super.key});
  final bool isPending;

  Color get _statusColor => isPending
      ? AgrisellColors.statusOrangeText
      : AgrisellColors.statusRedText;

  Color get _statusBackground => isPending
      ? AgrisellColors.statusOrangeBackground
      : AgrisellColors.statusRedBackground;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: _statusBackground,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _statusColor.withValues(alpha: .24)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AgrisellColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isPending ? Icons.hourglass_top_rounded : Icons.cancel_rounded,
            color: _statusColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPending ? 'Pending verification' : 'Application not approved',
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isPending
                    ? 'Your information and documents are waiting for review.'
                    : 'Please contact support for the available next steps.',
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class RiderApplicationNextStepsCard extends StatelessWidget {
  const RiderApplicationNextStepsCard({required this.isPending, super.key});
  final bool isPending;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AgrisellColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AgrisellColors.borderLine),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: AgrisellColors.forestGreen,
          size: 21,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPending ? 'What happens next?' : 'Need assistance?',
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isPending
                    ? 'We will notify you when your account is ready to be activated.'
                    : 'Our support team can explain the next steps for your application.',
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
