import 'package:flutter/material.dart';
import '../styles/rider_profile_design_styles.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

class RiderProfileEmptyState extends StatelessWidget {
  const RiderProfileEmptyState({
    this.logistics = false,
    this.onRegister,
    super.key,
  });
  final bool logistics;
  final VoidCallback? onRegister;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 66,
                backgroundColor: AgrisellColors.forestSoft,
                child: Icon(
                  logistics
                      ? Icons.local_shipping_outlined
                      : Icons.assignment_ind_outlined,
                  size: 78,
                  color: AgrisellColors.deliveryGreen,
                ),
              ),
              CircleAvatar(
                radius: 21,
                backgroundColor: logistics
                    ? AgrisellColors.statusRedText
                    : AgrisellColors.authGreen,
                child: Icon(
                  logistics ? Icons.close_rounded : Icons.add_rounded,
                  color: AgrisellColors.surface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            logistics ? 'No logistics company assigned' : 'No rider profile',
            textAlign: TextAlign.center,
            style: RiderProfileDesignStyles.heading,
          ),
          const SizedBox(height: 14),
          Text(
            logistics
                ? 'You can still receive assignments when approved.'
                : 'Complete rider registration to view account and vehicle details.',
            textAlign: TextAlign.center,
            style: RiderProfileDesignStyles.muted,
          ),
          if (!logistics && onRegister != null) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: RiderProfileDesignStyles.primary,
                onPressed: onRegister,
                child: const Text('Complete registration'),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
