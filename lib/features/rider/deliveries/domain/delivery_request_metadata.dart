enum ProductHandlingType {
  perishable,
  fragile,
  keepDry,
  temperatureSensitive,
  doNotStack,
  handleCarefully,
  heavyLoad,
  largePackage,
}

extension ProductHandlingTypeDetails on ProductHandlingType {
  String get label => switch (this) {
    ProductHandlingType.perishable => 'Perishable',
    ProductHandlingType.fragile => 'Fragile',
    ProductHandlingType.keepDry => 'Keep dry',
    ProductHandlingType.temperatureSensitive => 'Temperature sensitive',
    ProductHandlingType.doNotStack => 'Do not stack',
    ProductHandlingType.handleCarefully => 'Handle carefully',
    ProductHandlingType.heavyLoad => 'Heavy load',
    ProductHandlingType.largePackage => 'Large package',
  };

  bool get needsProvenVehicleCapability => switch (this) {
    ProductHandlingType.temperatureSensitive ||
    ProductHandlingType.largePackage => true,
    _ => false,
  };
}

class ProductHandlingRequirement {
  const ProductHandlingRequirement({
    required this.type,
    this.instructions = '',
    this.requiresRiderAcknowledgement = false,
  });

  final ProductHandlingType type;
  final String instructions;
  final bool requiresRiderAcknowledgement;
}

class PackageDimensions {
  const PackageDimensions({
    required this.lengthCm,
    required this.widthCm,
    required this.heightCm,
  });

  final double lengthCm;
  final double widthCm;
  final double heightCm;

  String get label =>
      '${lengthCm.toStringAsFixed(0)} x ${widthCm.toStringAsFixed(0)} x '
      '${heightCm.toStringAsFixed(0)} cm';
}

class DeliveryFeeBreakdown {
  const DeliveryFeeBreakdown({
    required this.baseFee,
    double distanceFee = 0,
    double? pickupDistanceFee,
    this.deliveryDistanceFee = 0,
    double weightAdjustment = 0,
    double? productWeightFee,
    double urgencyAdjustment = 0,
    double? urgencyFee,
    this.vehicleAdjustment = 0,
    this.perishableProductFee = 0,
    this.waitingFee = 0,
    this.returnFee = 0,
    this.additionalStopFee = 0,
    this.incentive = 0,
    this.bonus = 0,
    this.deduction = 0,
    this.penalty = 0,
    this.otherAdjustment = 0,
    this.currencyCode = 'PHP',
  }) : pickupDistanceFee = pickupDistanceFee ?? distanceFee,
       productWeightFee = productWeightFee ?? weightAdjustment,
       urgencyFee = urgencyFee ?? urgencyAdjustment;

  final double baseFee;
  final double pickupDistanceFee;
  final double deliveryDistanceFee;
  final double productWeightFee;
  final double vehicleAdjustment;
  final double urgencyFee;
  final double perishableProductFee;
  final double waitingFee;
  final double returnFee;
  final double additionalStopFee;
  final double incentive;
  final double bonus;
  final double deduction;
  final double penalty;
  final double otherAdjustment;
  final String currencyCode;

  double get distanceFee => pickupDistanceFee + deliveryDistanceFee;
  double get weightAdjustment => productWeightFee;
  double get urgencyAdjustment => urgencyFee;

  double get grossTotal =>
      baseFee +
      pickupDistanceFee +
      deliveryDistanceFee +
      productWeightFee +
      vehicleAdjustment +
      urgencyFee +
      perishableProductFee +
      waitingFee +
      returnFee +
      additionalStopFee +
      incentive +
      bonus +
      otherAdjustment;

  double get total => grossTotal - deduction - penalty;

  List<DeliveryFeeComponent> get components => [
    DeliveryFeeComponent('Base fee', baseFee),
    DeliveryFeeComponent('Pickup-distance fee', pickupDistanceFee),
    DeliveryFeeComponent('Delivery-distance fee', deliveryDistanceFee),
    DeliveryFeeComponent('Product-weight fee', productWeightFee),
    DeliveryFeeComponent('Vehicle adjustment', vehicleAdjustment),
    DeliveryFeeComponent('Urgency fee', urgencyFee),
    DeliveryFeeComponent('Perishable-product fee', perishableProductFee),
    DeliveryFeeComponent('Waiting fee', waitingFee),
    DeliveryFeeComponent('Return fee', returnFee),
    DeliveryFeeComponent('Additional-stop fee', additionalStopFee),
    DeliveryFeeComponent('Incentive', incentive),
    DeliveryFeeComponent('Bonus', bonus),
    DeliveryFeeComponent('Deduction', -deduction),
    DeliveryFeeComponent('Penalty', -penalty),
  ];
}

class DeliveryFeeComponent {
  const DeliveryFeeComponent(this.label, this.amount);

  final String label;
  final double amount;
}
