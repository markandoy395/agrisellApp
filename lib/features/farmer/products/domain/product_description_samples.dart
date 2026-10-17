import 'package:agresell_app/features/shared/products/domain/product_categories.dart';

abstract final class ProductDescriptionSamples {
  static const Map<String, List<String>> _byCategory = {
    ProductCategories.vegetables: [
      'Freshly harvested farm vegetables, crisp and clean, sorted daily for household cooking.',
      'Locally grown leafy and root vegetables picked at peak freshness with firm texture.',
      'Farm-fresh vegetables cultivated with clean water and careful handling from field to pack.',
      'Crisp, tender harvest sorted by size and quality, ideal for everyday home meals.',
      'Naturally grown seasonal vegetables with vibrant color and natural farm flavor.',
      'Hand-picked morning harvest, washed and trimmed for immediate kitchen preparation.',
      'High-quality highland and lowland vegetables packed fresh to preserve crunch and nutrients.',
      'Uniform, blemish-free vegetables harvested today and kept cool for lasting freshness.',
      'Wholesome farm produce grown using sustainable practices, great for stir-fries and soups.',
      'Tender, freshly cut vegetables with rich natural taste and minimal post-harvest handling.',
      'Clean, well-sorted vegetable batch with consistent size, ideal for home or bulk buyers.',
      'Sun-grown local vegetables harvested early in the morning to lock in moisture and crispness.',
      'Carefully selected garden-fresh produce with firm stems and vibrant, healthy leaves.',
      'Direct-from-farm vegetables packed in breathable bundles to stay fresh during delivery.',
      'Nutrient-rich fresh harvest with natural crunch, ready for salads, stews, and daily dishes.',
    ],
    ProductCategories.fruits: [
      'Naturally ripened farm fruits with sweet aroma, firm flesh, and vibrant skin.',
      'Hand-picked seasonal fruits harvested at peak maturity for rich, juicy flavor.',
      'Fresh orchard harvest sorted for uniform size, sweetness, and clean appearance.',
      'Sun-ripened local fruits carefully cushioned and packed to prevent bruising in transit.',
      'Sweet, refreshing farm-fresh fruits ideal for table serving, smoothies, and desserts.',
      'Tree-ripened harvest with balanced sweetness and natural juiciness in every bite.',
      'Newly harvested fruits selected for firm texture, bright color, and long shelf life.',
      'Locally grown tropical fruits picked fresh from the farm for maximum flavor and nutrition.',
      'Clean, grade-sorted fruit batch with natural sweetness and no artificial ripening.',
      'Plump, aromatic fruits harvested this week and stored in cool, shaded farm crates.',
      'Direct-from-orchard fruits with crisp bite and refreshing taste for the whole family.',
      'Carefully graded fresh fruits with smooth skin and rich pulp, ready to eat or chill.',
      'Farm-selected sweet harvest grown in fertile soil for full-bodied tropical flavor.',
      'Freshly picked fruit bundle with consistent ripeness, great for snacks and fresh juices.',
      'Quality-checked seasonal fruits with natural nectar sweetness and firm, healthy rinds.',
    ],
    ProductCategories.nuts: [
      'Clean, sun-dried farm nuts with crisp kernel texture and rich, natural nutty aroma.',
      'Freshly shelled and sorted local nuts, carefully dried for long-lasting crunch.',
      'Well-graded whole nuts with uniform kernel size, ideal for roasting, baking, or snacking.',
      'Naturally cured harvest stored in dry, airtight conditions to preserve natural oils.',
      'Hand-selected quality nuts free from broken shells, moisture damage, and impurities.',
      'Farm-fresh raw nuts with full, buttery flavor and firm bite in every batch.',
      'Properly dried mature nuts harvested at peak season for superior taste and shelf life.',
      'Cleanly processed local nut harvest, great for confectionery, cooking, and trail mixes.',
      'Premium whole kernels with consistent quality, packed dry to maintain natural freshness.',
      'Small-batch farm nuts sun-cured slowly to lock in natural sweetness and crunch.',
      'Sorted high-yield nuts with plump kernels and clean skins, ready for kitchen or retail use.',
      'Wholesome, chemical-free farm nuts with rich flavor and dependable storage quality.',
    ],
    ProductCategories.fruitTrees: [
      'Healthy, well-rooted fruit tree seedling grown in rich nursery soil, ready for transplanting.',
      'Vigorous grafted fruit tree sapling with strong stem and disease-resistant rootstock.',
      'Nursery-hardened young fruit tree with lush foliage, acclimated to local sun and rain.',
      'Early-bearing fruit tree variety raised in individual polybags for safe, easy planting.',
      'Strong, pest-free planting stock selected from high-yielding mother trees on our farm.',
      'Well-established fruit tree seedling with active new shoots and healthy fibrous roots.',
      'True-to-type propagated fruit tree ideal for backyard orchards or commercial farm plots.',
      'Sun-hardened sapling with sturdy trunk development, ready for field or container growing.',
      'Carefully nurtured fruit tree stock with balanced canopy growth and clean leaves.',
      'High-survival nursery seedling grown with organic compost for fast root establishment.',
      'Quality grafted planting material bred for sweet fruit production and sturdy growth.',
      'Farm-raised fruit tree sapling inspected for root health and vigorous vegetative growth.',
    ],
    ProductCategories.spices: [
      'Aromatic farm-fresh spices harvested at peak essential oil content for bold kitchen flavor.',
      'Clean, hand-sorted local spices with pungent aroma and vibrant natural color.',
      'Newly harvested culinary spices, washed and air-dried to preserve rich fragrance.',
      'Potent, locally grown spice batch ideal for everyday seasoning, marinades, and broths.',
      'Fresh rhizomes, bulbs, and pods selected for firm texture and strong natural aroma.',
      'Sun-cured farm spices free from stems and dust, packed to lock in natural spice oils.',
      'Flavor-packed local harvest grown in fertile soil for intense heat and deep aroma.',
      'Carefully graded kitchen spices with uniform quality and long-lasting shelf freshness.',
      'Direct-from-farm aromatic spices that add authentic, vibrant taste to home-cooked meals.',
      'Pure, unadulterated local spice harvest with bold flavor and clean, dry finish.',
      'Hand-picked seasonal spices cured in shaded racks to retain natural color and potency.',
      'Fresh, high-aroma farm seasoning produce sorted daily for home cooks and food stalls.',
    ],
  };

  static const List<String> _defaultSamples = [
    'Freshly harvested farm produce, carefully sorted and packed for quality and lasting freshness.',
    'Locally grown agricultural produce picked at peak maturity and handled with care.',
    'Clean, farm-direct harvest with consistent size and natural flavor for everyday use.',
    'Quality-checked local farm batch prepared fresh for reliable household or bulk orders.',
    'Sustainably grown produce harvested early to maintain crisp texture and natural nutrients.',
    'Hand-selected farm goods graded for cleanliness, freshness, and dependable quality.',
    'Direct-from-farm harvest stored in cool, clean conditions for optimal shelf life.',
    'Wholesome local produce cultivated with care and packed fresh for safe delivery.',
    'Carefully inspected farm harvest offering natural taste and uniform quality per unit.',
    'Fresh seasonal farm stock prepared daily to give buyers the best local harvest.',
  ];

  static List<String> samplesFor(String? category) {
    final normalized = category?.trim();
    if (normalized != null && _byCategory.containsKey(normalized)) {
      return _byCategory[normalized]!;
    }
    return _defaultSamples;
  }

  static bool isKnownSample(String description) {
    final trimmed = description.trim();
    if (trimmed.isEmpty) return false;
    if (_defaultSamples.contains(trimmed)) return true;
    return _byCategory.values.any((samples) => samples.contains(trimmed));
  }

  static String nextSample({
    required String? category,
    required String currentDescription,
    int seed = 0,
  }) {
    final samples = samplesFor(category);
    final trimmed = currentDescription.trim();
    final currentIndex = samples.indexOf(trimmed);
    if (currentIndex >= 0) {
      return samples[(currentIndex + 1) % samples.length];
    }
    final safeSeed = seed < 0 ? 0 : seed;
    final candidateIndex = safeSeed % samples.length;
    final candidate = samples[candidateIndex];
    if (candidate == trimmed && samples.length > 1) {
      return samples[(candidateIndex + 1) % samples.length];
    }
    return candidate;
  }
}
