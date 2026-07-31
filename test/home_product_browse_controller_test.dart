import 'support/home_product_fixture.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HomeProductBrowseController controller;

  setUp(() => controller = HomeProductBrowseController());
  tearDown(() => controller.dispose());

  test('search matches produce, farmer, and location', () {
    controller.updateQuery('pumpkin');
    expect(
      controller.visibleProducts(testHomeProducts).map((product) => product.id),
      ['pumpkin-kalabasa'],
    );

    controller.updateQuery('cagayan');
    expect(controller.visibleProducts(testHomeProducts), hasLength(13));
  });

  test('category and availability filters work together', () {
    controller.selectCategory('Spices');
    expect(controller.visibleProducts(testHomeProducts), hasLength(2));

    controller.setAvailableOnly(true);
    final visible = controller.visibleProducts(testHomeProducts);
    expect(visible, hasLength(1));
    expect(visible.single.id, 'fresh-picks');
    expect(controller.activeFilterCount, 2);
  });

  test('saved-only mode and reset keep saved product data', () {
    controller.toggleSaved('pumpkin-kalabasa');
    controller.setSavedOnly(true);

    expect(controller.visibleProducts(testHomeProducts), hasLength(1));
    expect(controller.savedCount, 1);

    controller.resetDiscoveryOptions();
    expect(controller.visibleProducts(testHomeProducts), hasLength(13));
    expect(controller.isSaved('pumpkin-kalabasa'), isTrue);
  });

  test('price sorting returns products in numeric order', () {
    controller.setSort(HomeProductSort.priceHighToLow);
    final visible = controller.visibleProducts(testHomeProducts);

    expect(visible.first.price, '\u20B170');
    expect(visible.last.price, '\u20B115');
  });
}
