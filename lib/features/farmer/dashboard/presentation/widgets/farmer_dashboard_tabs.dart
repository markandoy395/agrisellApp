part of 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';

enum _FarmerDashboardTab { products, categories }

class _FarmerDashboardTabs extends StatelessWidget {
  const _FarmerDashboardTabs({
    required this.activeTab,
    required this.onChanged,
  });

  final _FarmerDashboardTab activeTab;
  final ValueChanged<_FarmerDashboardTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: FarmerDashboardTabsStyles.containerDecoration,
      child: Row(
        children: [
          _FarmerDashboardTabButton(
            label: 'Products',
            isActive: activeTab == _FarmerDashboardTab.products,
            onTap: () => onChanged(_FarmerDashboardTab.products),
          ),
          _FarmerDashboardTabButton(
            label: 'Categories',
            isActive: activeTab == _FarmerDashboardTab.categories,
            onTap: () => onChanged(_FarmerDashboardTab.categories),
          ),
        ],
      ),
    );
  }
}

class _FarmerDashboardTabButton extends StatelessWidget {
  const _FarmerDashboardTabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isActive
        ? AgrisellColors.authGreen
        : AgrisellColors.surface;
    final textColor = isActive
        ? AgrisellColors.surface
        : AgrisellColors.brandBlack;
    final radius = isActive
        ? const BorderRadius.vertical(top: Radius.circular(21))
        : BorderRadius.zero;

    return Expanded(
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FarmerDashboardTabsStyles.labelText(textColor),
            ),
          ),
        ),
      ),
    );
  }
}
