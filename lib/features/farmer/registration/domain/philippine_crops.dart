/// Crop names from the Philippine Statistics Authority's 2019–2023
/// Crops Statistics of the Philippines (tables 2–49).
/// https://psada.psa.gov.ph/catalog/313/related-materials
abstract final class PhilippineCrops {
  static const names = <String>[
    'Palay',
    'Corn',
    'Banana',
    'Calamansi',
    'Durian',
    'Lanzones',
    'Mandarin',
    'Mango',
    'Mangosteen',
    'Orange',
    'Papaya',
    'Pineapple',
    'Rambutan',
    'Tamarind',
    'Watermelon',
    'Abaca',
    'Cacao',
    'Cashew',
    'Coconut',
    'Coffee',
    'Oil Palm',
    'Rubber',
    'Sugarcane',
    'Tobacco',
    'Ampalaya Fruit',
    'Asparagus',
    'Broccoli',
    'Cabbage',
    'Carrots',
    'Cassava',
    'Cauliflower',
    'Eggplant',
    'Garlic',
    'Ginger',
    'Bottle Gourd',
    'Snap Beans/Habitchuelas',
    'Lettuce',
    'Mung Bean/Mongo',
    "Lady's Finger/Okra",
    'Onion',
    'Peanut',
    'Chinese Pechay',
    'Native Pechay',
    'Potato',
    'Sweet Potato/Camote',
    'Taro/Gabi',
    'Tomato',
    'Greater Yam/Ubi',
  ];

  static List<String> parseSelection(String value) => value
      .split(',')
      .map((crop) => crop.trim())
      .where((crop) => crop.isNotEmpty)
      .toList(growable: false);
}
