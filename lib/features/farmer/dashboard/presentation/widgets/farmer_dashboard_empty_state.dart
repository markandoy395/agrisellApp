part of 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';

class _FarmerDashboardEmptyState extends StatelessWidget {
  const _FarmerDashboardEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 34, 20, 10),
    child: Column(
      children: [
        const Icon(
          Icons.inventory_2_outlined,
          color: AgrisellColors.authGreen,
          size: 34,
        ),
        const SizedBox(height: 9),
        Text(
          message,
          textAlign: TextAlign.center,
          style: SharedPresentationStyles.mutedCaptionSemibold,
        ),
      ],
    ),
  );
}
