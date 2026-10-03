class PickupConditionChecklist {
  const PickupConditionChecklist({
    required this.correctProduct,
    required this.correctQuantity,
    required this.correctWeight,
    required this.securePackaging,
    required this.notVisiblyDamaged,
    required this.matchesRequest,
    required this.fitsVehicle,
    required this.handlingInstructionsReceived,
    required this.confirmedQuantity,
    required this.confirmedWeightKg,
  });

  final bool correctProduct;
  final bool correctQuantity;
  final bool correctWeight;
  final bool securePackaging;
  final bool notVisiblyDamaged;
  final bool matchesRequest;
  final bool fitsVehicle;
  final bool handlingInstructionsReceived;
  final int confirmedQuantity;
  final double confirmedWeightKg;

  bool get allItemsChecked =>
      correctProduct &&
      correctQuantity &&
      correctWeight &&
      securePackaging &&
      notVisiblyDamaged &&
      matchesRequest &&
      fitsVehicle &&
      handlingInstructionsReceived;

  bool get hasValidQuantity => confirmedQuantity > 0;
  bool get hasValidWeight =>
      confirmedWeightKg.isFinite && confirmedWeightKg >= 0;
  bool get passes => allItemsChecked && hasValidQuantity && hasValidWeight;
}
