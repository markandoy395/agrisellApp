enum ProductProductionStage { growing, harvestingSoon, harvested }

extension ProductProductionStageValue on ProductProductionStage {
  String get databaseValue => switch (this) {
    ProductProductionStage.growing => 'growing',
    ProductProductionStage.harvestingSoon => 'harvesting_soon',
    ProductProductionStage.harvested => 'harvested',
  };

  String get farmerLabel => switch (this) {
    ProductProductionStage.growing => 'Growing',
    ProductProductionStage.harvestingSoon => 'Harvesting soon',
    ProductProductionStage.harvested => 'Harvested',
  };

  String get buyerLabel => farmerLabel;
}

ProductProductionStage productProductionStageFromDatabase(Object? value) {
  final normalized = value?.toString().trim().toLowerCase() ?? '';
  return switch (normalized) {
    'growing' || 'pre-order' || 'pre_order' => ProductProductionStage.growing,
    'harvesting_soon' ||
    'harvesting soon' ||
    'ready for harvest' => ProductProductionStage.harvestingSoon,
    _ => ProductProductionStage.harvested,
  };
}
