part of 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';

class _FarmerDashboardHeader extends StatelessWidget {
  const _FarmerDashboardHeader({
    required this.horizontalPadding,
    required this.searchController,
    required this.onSearchChanged,
    required this.onMenuTap,
  });

  final double horizontalPadding;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onMenuTap;

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
              Expanded(
                child: _FarmerSearchBar(
                  controller: searchController,
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 8),
              _IconAssetButton(
                semanticLabel: 'Menu',
                icon: AgrisellAssets.iconMenu,
                size: 31,
                onTap: onMenuTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FarmerSearchBar extends StatelessWidget {
  const _FarmerSearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

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
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: AgrisellColors.brandBlack,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search products',
          hintStyle: TextStyle(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.55),
            fontSize: 12,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
          prefixIcon: const Icon(Icons.search_rounded, size: 21),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded, size: 19),
                ),
        ),
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
