import 'package:flutter/material.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/farmer/profile/domain/farmer_history_section.dart';
import 'package:agresell_app/features/farmer/profile/presentation/screens/farmer_history_screen.dart';
import 'farmer_profile_style.dart';

class FarmerHistoryCard extends StatelessWidget {
  const FarmerHistoryCard({super.key});

  @override
  Widget build(BuildContext context) => FarmerProfileCard(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('My orders', style: FarmerProfileStyle.heading),
              ),
              InkWell(
                onTap: () => _openHistory(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View all',
                        style: TextStyle(
                          color: FarmerProfileStyle.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: FarmerProfileStyle.green,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: HistoryShortcut(
                  label: 'To Ship',
                  icon: Icons.local_shipping_outlined,
                  section: FarmerHistorySection.toShip,
                ),
              ),
              Expanded(
                child: HistoryShortcut(
                  label: 'Completed',
                  icon: Icons.check_circle_outline_rounded,
                  section: FarmerHistorySection.completed,
                ),
              ),
              Expanded(
                child: HistoryShortcut(
                  label: 'Feedback',
                  icon: Icons.rate_review_outlined,
                  section: FarmerHistorySection.feedback,
                ),
              ),
              Expanded(
                child: HistoryShortcut(
                  label: 'Confirm',
                  icon: Icons.verified_outlined,
                  section: FarmerHistorySection.confirm,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  static void _openHistory(
    BuildContext context, {
    FarmerHistorySection section = FarmerHistorySection.toShip,
  }) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => FarmerHistoryScreen(initialSection: section),
      ),
    );
  }
}

class HistoryShortcut extends StatelessWidget {
  const HistoryShortcut({
    required this.label,
    required this.icon,
    required this.section,
    super.key,
  });
  final String label;
  final IconData icon;
  final FarmerHistorySection section;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: () => FarmerHistoryCard._openHistory(context, section: section),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 58,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5EE), Color(0xFFD1EDDF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: FarmerProfileStyle.borderSubtle,
                  width: 1,
                ),
              ),
              child: Icon(icon, color: FarmerProfileStyle.green, size: 28),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: FarmerProfileStyle.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
