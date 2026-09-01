import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';

class HomeBannerRepository {
  const HomeBannerRepository();

  Future<List<HomeBanner>> loadActiveBanners() async {
    if (!AgrisellSupabase.isInitialized) return const [];
    final rows = await AgrisellSupabase.client.rpc<List<dynamic>>(
      'marketplace_home_banners',
    );
    return homeBannersFromRows(rows.whereType<Map<String, dynamic>>());
  }
}

List<HomeBanner> homeBannersFromRows(Iterable<Map<String, dynamic>> rows) {
  final campaigns = <String, List<Map<String, dynamic>>>{};
  var rowWithoutSaleId = 0;
  for (final row in rows) {
    final bannerId = row['banner_id']?.toString().trim();
    final saleId =
        row['campaign_sale_id']?.toString().trim().isNotEmpty ?? false
        ? row['campaign_sale_id']?.toString().trim()
        : row['sale_id']?.toString().trim();
    final stableId = bannerId?.isNotEmpty ?? false ? bannerId : saleId;
    final campaignKey = stableId == null || stableId.isEmpty
        ? 'missing-sale-id-${rowWithoutSaleId++}'
        : stableId;
    campaigns.putIfAbsent(campaignKey, () => []).add(row);
  }
  return campaigns.values
      .map(_homeBannerFromCampaignRows)
      .toList(growable: false);
}

HomeBanner _homeBannerFromCampaignRows(List<Map<String, dynamic>> rows) {
  final row = rows.first;
  if (row['banner_source'] != null) return _homeBannerFromUnifiedRow(row);

  final type = row['discount_type']?.toString();
  final value = num.tryParse(row['discount_value']?.toString() ?? '') ?? 0;
  final productNames = rows
      .map((item) => item['commodity_name']?.toString().trim() ?? '')
      .where((name) => name.isNotEmpty)
      .toSet()
      .toList(growable: false);
  final productScope = switch (productNames.length) {
    0 => 'SELECTED PRODUCTS',
    1 => productNames.first,
    _ => '${productNames.first} + ${productNames.length - 1} more',
  };
  return HomeBanner(
    id: 'campaign:${row['sale_id']}',
    source: HomeBannerSource.campaign,
    campaignSaleId: _integer(row['sale_id']),
    image: AgrisellAssets.homeBannerVegetables,
    imageUrl: _text(row['image_url']),
    prefix: 'Save ',
    highlight: switch (type) {
      'percentage' =>
        '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2)}%',
      'amount' => '₱${value.toStringAsFixed(0)}',
      _ => 'Now',
    },
    subtitle: row['sale_name']?.toString().trim().isNotEmpty ?? false
        ? row['sale_name'].toString()
        : 'Limited-time offer',
    title: productScope.toUpperCase(),
    expiryLabel: _date(row['ends_at']) ?? 'Limited time',
    expiresAt: DateTime.tryParse(row['ends_at']?.toString() ?? ''),
  );
}

HomeBanner _homeBannerFromUnifiedRow(Map<String, dynamic> row) {
  final source = row['banner_source']?.toString() == 'campaign'
      ? HomeBannerSource.campaign
      : HomeBannerSource.manual;
  return HomeBanner(
    id: row['banner_id']?.toString() ?? '',
    source: source,
    campaignSaleId: _integer(row['campaign_sale_id']),
    image: AgrisellAssets.homeBannerVegetables,
    imageUrl: _text(row['image_url']),
    prefix: row['prefix']?.toString() ?? '',
    highlight: row['highlight']?.toString() ?? '',
    subtitle: row['subtitle']?.toString() ?? '',
    title: row['title']?.toString().trim().isNotEmpty ?? false
        ? row['title'].toString()
        : 'FRESH PRODUCTS',
    expiryLabel: _date(row['ends_at']) ?? 'Limited time',
    expiresAt: DateTime.tryParse(row['ends_at']?.toString() ?? ''),
  );
}

int? _integer(Object? value) => int.tryParse(value?.toString() ?? '');

String? _text(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

String? _date(Object? value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return null;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
