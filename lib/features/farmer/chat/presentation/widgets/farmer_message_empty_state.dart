import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/farmer/chat/presentation/widgets/message_filter_tabs.dart';

class FarmerMessageEmptyState extends StatelessWidget {
  const FarmerMessageEmptyState({required this.filter, super.key});

  final FarmerMessageFilter filter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.forum_outlined,
            color: AgrisellColors.authGreen,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'No ${filter.label.toLowerCase()} messages',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 14,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Buyer conversations connected to products and orders will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
