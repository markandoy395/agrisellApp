import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';

class FarmerShopHeader extends StatelessWidget {
  const FarmerShopHeader({
    required this.coverImage,
    required this.coverImageUrl,
    required this.height,
    required this.searchController,
    required this.onSearchChanged,
    required this.onBack,
    super.key,
  });

  final String coverImage;
  final String? coverImageUrl;
  final double height;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onBack;

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
                  _HeaderIconButton(
                    semanticLabel: 'Back to farmers',
                    icon: Icons.arrow_back_rounded,
                    onTap: onBack,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ShopSearchField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _HeaderIconButton(
                    semanticLabel: 'More shop options',
                    icon: Icons.more_vert_rounded,
                    onTap: () {},
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.semanticLabel,
    required this.icon,
    required this.onTap,
  });

  final String semanticLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 38,
        child: Material(
          color: AgrisellColors.brandBlack.withValues(alpha: 0.42),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(icon, color: AgrisellColors.surface, size: 22),
          ),
        ),
      ),
    );
  }
}
