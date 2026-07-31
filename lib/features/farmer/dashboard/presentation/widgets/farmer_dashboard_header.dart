part of 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';

class _FarmerDashboardHeader extends StatelessWidget {
  const _FarmerDashboardHeader({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 0),
      child: Column(
        children: [
          const SizedBox(
            height: 38,
            child: Center(
              child: SizedBox(
                width: 148,
                height: 34,
                child: ResponsiveAssetImage(
                  asset: AgrisellAssets.logoLandscape,
                  width: 148,
                  height: 34,
                  fit: BoxFit.contain,
                  semanticLabel: 'AgriSell',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: _FarmerSearchBar()),
              const SizedBox(width: 8),
              _IconAssetButton(
                semanticLabel: 'Menu',
                icon: AgrisellAssets.iconMenu,
                size: 31,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FarmerSearchBar extends StatelessWidget {
  const _FarmerSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.13),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Search in AgriSell',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AgrisellColors.brandBlack.withValues(alpha: 0.55),
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          ResponsiveAssetImage(
            asset: AgrisellAssets.iconSearch,
            width: 23,
            height: 23,
            color: AgrisellColors.brandBlack,
            colorBlendMode: BlendMode.srcIn,
            semanticLabel: 'Search',
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

class _IconAssetButton extends StatelessWidget {
  const _IconAssetButton({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
    this.size = 32,
  });

  final String semanticLabel;
  final String icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: 26,
        child: ResponsiveAssetImage(
          asset: icon,
          width: size,
          height: size,
          fit: BoxFit.contain,
          color: AgrisellColors.brandBlack,
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    );
  }
}
