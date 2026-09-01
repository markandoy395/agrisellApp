enum HomeBannerSource { manual, campaign }

class HomeBanner {
  const HomeBanner({
    required this.image,
    required this.prefix,
    required this.highlight,
    required this.subtitle,
    required this.title,
    required this.expiryLabel,
    this.id = '',
    this.source = HomeBannerSource.manual,
    this.campaignSaleId,
    this.imageUrl,
    this.expiresAt,
  });

  final String image;
  final String id;
  final HomeBannerSource source;
  final int? campaignSaleId;
  final String? imageUrl;
  final String prefix;
  final String highlight;
  final String subtitle;
  final String title;
  final String expiryLabel;

  /// The exclusive end of the promotion window. A banner is hidden on or
  /// after this timestamp, while the original product pricing remains intact.
  final DateTime? expiresAt;

  bool get opensSaleCampaign =>
      source == HomeBannerSource.campaign && campaignSaleId != null;

  bool isExpiredAt(DateTime now) =>
      expiresAt != null && !expiresAt!.isAfter(now);
}
