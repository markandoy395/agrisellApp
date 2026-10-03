import 'package:flutter/material.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';
import '../../styles/home_banner_styles.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'home_banner_expiry_badge.dart';

class HomePromoBanner extends StatelessWidget {
  const HomePromoBanner({required this.banner, this.onTap, super.key});
  final HomeBanner banner;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: HomeBannerStyles.promoDecoration,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 300;
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: constraints.maxWidth * 0.34,
                  right: -constraints.maxWidth * 0.1,
                  bottom: -constraints.maxHeight * 0.08,
                  height: constraints.maxHeight * 0.88,
                  child: ResponsiveAssetImage(
                    asset: banner.image,
                    alignment: Alignment.bottomRight,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    semanticLabel: '${banner.title} promotion',
                  ),
                ),
                Positioned(
                  left: compact ? 20 : 22,
                  top: compact ? 20 : 24,
                  width: constraints.maxWidth * 0.48,
                  child: FittedBox(
                    alignment: Alignment.topLeft,
                    fit: BoxFit.scaleDown,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          maxLines: 1,
                          text: TextSpan(
                            text: banner.prefix,
                            style: HomeBannerStyles.prefixText(compact),
                            children: [
                              TextSpan(
                                text: banner.highlight,
                                style: HomeBannerStyles.highlightText(compact),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          banner.subtitle,
                          style: HomeBannerStyles.subtitleText(compact),
                        ),
                        if (banner.source == HomeBannerSource.campaign) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: HomeBannerStyles.campaignPadding,
                            decoration: HomeBannerStyles.campaignDecoration,
                            child: Text(
                              '${banner.title.replaceAll('\n', ' ')}  •  ON SALE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: HomeBannerStyles.campaignText(compact),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ] else
                          const SizedBox(height: 5),
                        Text(
                          banner.title,
                          style: HomeBannerStyles.productText(compact),
                        ),
                        const SizedBox(height: 10),
                        HomeBannerExpiryBadge(banner: banner, compact: compact),
                      ],
                    ),
                  ),
                ),
                if (onTap != null)
                  Positioned(
                    right: compact ? 14 : 18,
                    bottom: 14,
                    child: Container(
                      padding: HomeBannerStyles.shopPadding,
                      decoration: HomeBannerStyles.shopDecoration,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('SHOP SALE', style: HomeBannerStyles.shopText),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: AgrisellColors.surface,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
    if (onTap == null) return content;
    return Semantics(
      button: true,
      label: 'Open ${banner.subtitle} sale products',
      child: content,
    );
  }
}
