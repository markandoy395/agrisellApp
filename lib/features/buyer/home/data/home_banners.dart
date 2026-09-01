import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';

final List<HomeBanner> homeBanners = <HomeBanner>[
  HomeBanner(
    id: 'campaign:preview',
    source: HomeBannerSource.campaign,
    image: AgrisellAssets.homeBannerVegetables,
    prefix: 'Save Up to ',
    highlight: '50%',
    subtitle: 'Discount of',
    title: 'VEGETABLE\nPRODUCT',
    expiryLabel: 'Aug 31, 2026',
    expiresAt: DateTime(2026, 9, 1),
  ),
];
