import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

final List<HomeProduct> testHomeProducts = List<HomeProduct>.unmodifiable([
  _product(
    id: 'pumpkin-kalabasa',
    name: 'Pumpkin / Kalabasa',
    price: '\u20B115',
  ),
  _product(
    id: 'seasonal-harvest',
    name: 'Seasonal Harvest',
    price: '\u20B135',
    category: 'Fruits',
  ),
  _product(id: 'local-produce', name: 'Local Produce', price: '\u20B120'),
  _product(id: 'farm-pick', name: 'Farm Pick', price: '\u20B145'),
  _product(id: 'fresh-crop', name: 'Fresh Crop', price: '\u20B150'),
  _product(id: 'market-fresh', name: 'Market Fresh', price: '\u20B155'),
  _product(
    id: 'unavailable-produce',
    name: 'Unavailable Produce',
    price: '\u20B160',
    isAvailable: false,
  ),
  _product(id: 'garden-mix', name: 'Garden Mix', price: '\u20B125'),
  _product(id: 'organic-produce', name: 'Organic Produce', price: '\u20B130'),
  _product(id: 'harvest-box', name: 'Harvest Box', price: '\u20B165'),
  _product(id: 'farm-fresh', name: 'Farm Fresh', price: '\u20B170'),
  _product(
    id: 'fresh-picks',
    name: 'Fresh Picks',
    price: '\u20B140',
    category: 'Spices',
  ),
  _product(
    id: 'unavailable-spice',
    name: 'Unavailable Spice',
    price: '\u20B118',
    category: 'Spices',
    isAvailable: false,
  ),
]);

HomeProduct _product({
  required String id,
  required String name,
  required String price,
  String category = 'Vegetable',
  bool isAvailable = true,
  String? imageUrl,
}) => HomeProduct(
  id: id,
  name: name,
  price: price,
  unit: 'per kg',
  image: AgrisellAssets.homeBannerVegetables,
  harvestDate: 'January 1, 2030',
  availableWeight: isAvailable ? '10 kg available' : '0 kg available',
  sellerName: 'Test Farmer',
  sellerLocation: 'Cagayan de Oro',
  category: category,
  isAvailable: isAvailable,
  imageUrl: imageUrl,
);
