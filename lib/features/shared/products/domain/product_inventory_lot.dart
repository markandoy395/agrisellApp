enum ProductInventoryDateType {
  freshProduce,
  packagedFood,
  nonPerishable;

  String get databaseValue => switch (this) {
    freshProduce => 'fresh_produce',
    packagedFood => 'packaged_food',
    nonPerishable => 'non_perishable',
  };

  String get farmerLabel => switch (this) {
    freshProduce => 'Fresh produce',
    packagedFood => 'Packaged food',
    nonPerishable => 'No expiration',
  };

  String get guidance => switch (this) {
    freshProduce => 'Set the final date this batch should be offered for sale.',
    packagedFood => 'Copy the expiration date and lot code from the package.',
    nonPerishable => 'Use for planting materials and other non-food products.',
  };
}

ProductInventoryDateType productInventoryDateTypeFromDatabase(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'packaged_food' => ProductInventoryDateType.packagedFood,
    'non_perishable' => ProductInventoryDateType.nonPerishable,
    _ => ProductInventoryDateType.freshProduce,
  };
}

class ProductInventoryLotDraft {
  const ProductInventoryLotDraft({
    required this.dateType,
    this.harvestedAt,
    this.sellUntil,
    this.expiresAt,
    this.lotCode,
    this.storageInstructions,
  });

  final ProductInventoryDateType dateType;
  final DateTime? harvestedAt;
  final DateTime? sellUntil;
  final DateTime? expiresAt;
  final String? lotCode;
  final String? storageInstructions;

  DateTime? get marketableUntil => switch (dateType) {
    ProductInventoryDateType.freshProduce => sellUntil,
    ProductInventoryDateType.packagedFood => expiresAt,
    ProductInventoryDateType.nonPerishable => null,
  };

  Map<String, String> validationErrors({
    required DateTime today,
    DateTime? earliestMarketableDate,
    bool allowFutureHarvest = false,
  }) {
    final errors = <String, String>{};
    final normalizedToday = _dateOnly(today);
    final harvestedDate = harvestedAt;
    final earliestDate = earliestMarketableDate;
    final harvest = harvestedDate == null ? null : _dateOnly(harvestedDate);
    final earliest = earliestDate == null
        ? harvest ?? normalizedToday
        : _dateOnly(earliestDate);

    if (dateType != ProductInventoryDateType.nonPerishable) {
      if (harvest == null) {
        errors['harvestedAt'] = 'Select the harvest or production date.';
      } else if (!allowFutureHarvest && harvest.isAfter(normalizedToday)) {
        errors['harvestedAt'] = 'The harvest date cannot be in the future.';
      }
    }

    if (dateType == ProductInventoryDateType.freshProduce) {
      final deadline = sellUntil == null ? null : _dateOnly(sellUntil!);
      if (deadline == null) {
        errors['sellUntil'] = 'Select the final selling date.';
      } else if (deadline.isBefore(normalizedToday)) {
        errors['sellUntil'] = 'The selling date cannot be in the past.';
      } else if (deadline.isBefore(earliest)) {
        errors['sellUntil'] = 'The selling date must be on or after harvest.';
      }
    }

    if (dateType == ProductInventoryDateType.packagedFood) {
      final deadline = expiresAt == null ? null : _dateOnly(expiresAt!);
      if (deadline == null) {
        errors['expiresAt'] = 'Select the printed expiration date.';
      } else if (deadline.isBefore(normalizedToday)) {
        errors['expiresAt'] = 'The expiration date cannot be in the past.';
      } else if (deadline.isBefore(earliest)) {
        errors['expiresAt'] = 'Expiration must be on or after production.';
      }
      if ((lotCode ?? '').trim().isEmpty) {
        errors['lotCode'] = 'Enter the package lot or batch code.';
      }
    }

    if ((lotCode ?? '').trim().length > 80) {
      errors['lotCode'] = 'Keep the lot code within 80 characters.';
    }
    if ((storageInstructions ?? '').trim().length > 240) {
      errors['storageInstructions'] =
          'Keep storage instructions within 240 characters.';
    }
    return errors;
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
