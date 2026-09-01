import 'package:agresell_app/features/buyer/home/data/home_banner_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups one thousand products into one sale campaign banner', () {
    final rows = List<Map<String, dynamic>>.generate(
      1000,
      (index) => {
        'sale_id': 42,
        'sale_name': 'Farm-wide sale',
        'discount_type': 'percentage',
        'discount_value': 20,
        'commodity_name': 'Product ${index + 1}',
        'ends_at': '2026-09-30T16:00:00+00:00',
      },
    );

    final banners = homeBannersFromRows(rows);

    expect(banners, hasLength(1));
    expect(banners.single.subtitle, 'Farm-wide sale');
    expect(banners.single.title, 'PRODUCT 1 + 999 MORE');
    expect(banners.single.highlight, '20%');
  });

  test('keeps separate sale campaigns as separate banners', () {
    final banners = homeBannersFromRows([
      {
        'sale_id': 1,
        'sale_name': 'Fruit sale',
        'discount_type': 'percentage',
        'discount_value': 10,
        'commodity_name': 'Mango',
      },
      {
        'sale_id': 2,
        'sale_name': 'Vegetable sale',
        'discount_type': 'percentage',
        'discount_value': 15,
        'commodity_name': 'Lettuce',
      },
    ]);

    expect(banners, hasLength(2));
    expect(banners.map((banner) => banner.title), ['MANGO', 'LETTUCE']);
  });

  test('keeps manual and campaign banners as separate sources', () {
    final banners = homeBannersFromRows([
      {
        'banner_id': 'campaign:9',
        'banner_source': 'campaign',
        'campaign_sale_id': 9,
        'prefix': 'Save ',
        'highlight': '25%',
        'subtitle': 'Harvest campaign',
        'title': 'MANGO + 20 MORE',
      },
      {
        'banner_id': 'manual:3',
        'banner_source': 'manual',
        'prefix': 'Discover ',
        'highlight': 'Local',
        'subtitle': 'Meet nearby growers',
        'title': 'FARMER STORIES',
      },
    ]);

    expect(banners, hasLength(2));
    expect(banners.first.opensSaleCampaign, isTrue);
    expect(banners.first.campaignSaleId, 9);
    expect(banners.last.opensSaleCampaign, isFalse);
  });
}
