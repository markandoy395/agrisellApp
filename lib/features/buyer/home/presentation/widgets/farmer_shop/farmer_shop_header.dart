import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/shared/widgets/buttons/circular_header_icon_button.dart';

enum FarmerShopMenuAction { viewAllProducts, messageFarmer }

class FarmerShopHeader extends StatelessWidget {
  const FarmerShopHeader({
    required this.coverImage,
    required this.coverImageUrl,
    required this.height,
    required this.searchController,
    required this.onSearchChanged,
    required this.onBack,
    required this.onMenuSelected,
    super.key,
  });

  final String coverImage;
  final String? coverImageUrl;
  final double height;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onBack;
  final ValueChanged<FarmerShopMenuAction> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ResponsiveAssetImage(
            asset: coverImage,
            imageUrl: coverImageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            semanticLabel: 'Farm cover photo',
            filterQuality: FilterQuality.medium,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AgrisellColors.brandBlack.withValues(alpha: 0.22),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: Row(
                children: [
                  CircularHeaderIconButton(
                    semanticLabel: 'Back to farmers',
                    icon: Icons.arrow_back_rounded,
                    onTap: onBack,
                    style: CircularHeaderIconButtonStyle.inkWell(
                      dimension: 38,
                      backgroundColor: AgrisellColors.brandBlack.withValues(
                        alpha: 0.42,
                      ),
                      iconColor: AgrisellColors.surface,
                      iconSize: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ShopSearchField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<FarmerShopMenuAction>(
                    tooltip: 'More shop options',
                    onSelected: onMenuSelected,
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: FarmerShopMenuAction.viewAllProducts,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.storefront_outlined),
                          title: Text('View all products'),
                        ),
                      ),
                      PopupMenuItem(
                        value: FarmerShopMenuAction.messageFarmer,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.chat_bubble_outline_rounded),
                          title: Text('Message farmer'),
                        ),
                      ),
                    ],
                    child: Semantics(
                      button: true,
                      label: 'More shop options',
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AgrisellColors.brandBlack.withValues(
                            alpha: 0.42,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: AgrisellColors.surface,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopSearchField extends StatelessWidget {
  const _ShopSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AgrisellColors.brandBlack.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(22),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            color: AgrisellColors.surface,
            fontSize: 12,
            height: 1.1,
          ),
          cursorColor: AgrisellColors.surface,
          decoration: InputDecoration(
            hintText: 'Search in shop',
            hintStyle: TextStyle(
              color: AgrisellColors.surface.withValues(alpha: 0.72),
              fontSize: 12,
              height: 1.1,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.fromLTRB(14, 10, 6, 8),
            suffixIconConstraints: const BoxConstraints.tightFor(
              width: 38,
              height: 38,
            ),
            suffixIcon: Icon(
              Icons.search_rounded,
              color: AgrisellColors.surface.withValues(alpha: 0.9),
              size: 19,
            ),
          ),
        ),
      ),
    );
  }
}
