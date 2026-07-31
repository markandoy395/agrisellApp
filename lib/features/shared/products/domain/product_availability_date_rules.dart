import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';

abstract final class ProductAvailabilityDateRules {
  static AvailabilityDateWindow windowFor({
    required ProductProductionStage productionStage,
    required ProductSaleStatus sellingOption,
    DateTime? utcNow,
  }) {
    final today = philippineToday(utcNow: utcNow);
    final requiresDate =
        productionStage != ProductProductionStage.harvested ||
        sellingOption == ProductSaleStatus.preOrder;
    if (!requiresDate) {
      return AvailabilityDateWindow.notRequired(today: today);
    }

    var minimumDays = switch (productionStage) {
      ProductProductionStage.harvested => 0,
      ProductProductionStage.growing => 1,
      ProductProductionStage.harvestingSoon => 1,
    };
    var maximumDays = switch (productionStage) {
      ProductProductionStage.harvestingSoon => 14,
      ProductProductionStage.growing || ProductProductionStage.harvested => 90,
    };
    if (sellingOption == ProductSaleStatus.preOrder) {
      minimumDays = minimumDays < 3 ? 3 : minimumDays;
      maximumDays = maximumDays > 90 ? 90 : maximumDays;
    }

    return AvailabilityDateWindow(
      isRequired: true,
      firstDate: today.add(Duration(days: minimumDays)),
      lastDate: today.add(Duration(days: maximumDays)),
      minimumDays: minimumDays,
      maximumDays: maximumDays,
    );
  }

  static DateTime philippineToday({DateTime? utcNow}) {
    final utc = (utcNow ?? DateTime.now().toUtc()).toUtc();
    final manila = utc.add(const Duration(hours: 8));
    return DateTime(manila.year, manila.month, manila.day);
  }
}

class AvailabilityDateWindow {
  const AvailabilityDateWindow({
    required this.isRequired,
    required this.firstDate,
    required this.lastDate,
    required this.minimumDays,
    required this.maximumDays,
  });

  factory AvailabilityDateWindow.notRequired({required DateTime today}) {
    return AvailabilityDateWindow(
      isRequired: false,
      firstDate: today,
      lastDate: today,
      minimumDays: 0,
      maximumDays: 0,
    );
  }

  final bool isRequired;
  final DateTime firstDate;
  final DateTime lastDate;
  final int minimumDays;
  final int maximumDays;

  String get guidance =>
      'Choose a date $minimumDays\u2013$maximumDays days from today.';

  bool includes(DateTime date) {
    final value = DateTime(date.year, date.month, date.day);
    return !value.isBefore(firstDate) && !value.isAfter(lastDate);
  }

  String? validationMessage(DateTime? date) {
    if (!isRequired) return null;
    if (date == null) return 'Select the expected availability date.';
    if (!includes(date)) {
      return 'Expected availability must be $minimumDays\u2013$maximumDays '
          'days from today.';
    }
    return null;
  }
}
