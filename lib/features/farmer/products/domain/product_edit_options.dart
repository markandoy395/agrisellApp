import 'dart:typed_data';

import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_categories.dart';
import 'package:agresell_app/features/shared/products/domain/product_availability_date_rules.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';

class ProductEditDateParts {
  const ProductEditDateParts({this.day, this.month, this.year});

  final String? day;
  final String? month;
  final String? year;
}

abstract final class ProductEditOptions {
  static const days = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
  ];
  static const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const categories = ProductCategories.values;

  static ProductEditDateParts datePartsFor(String value) {
    final pieces = value.split(',');
    if (pieces.length != 2) {
      return const ProductEditDateParts();
    }

    final year = pieces[1].trim();
    final monthDay = pieces[0].trim().split(' ');
    if (monthDay.length < 2) {
      return ProductEditDateParts(
        year: int.tryParse(year) == null ? null : year,
      );
    }

    final day = monthDay.last.trim();
    final month = monthDay.sublist(0, monthDay.length - 1).join(' ');

    return ProductEditDateParts(
      day: days.contains(day) ? day : null,
      month: months.contains(month) ? month : null,
      year: int.tryParse(year) == null ? null : year,
    );
  }

  static String stripPeso(String value) {
    return value.replaceFirst('\u20B1', '').trim();
  }

  static String stripKg(String value) {
    final trimmed = value.trim();
    if (trimmed.toLowerCase().endsWith('kg')) {
      return trimmed.substring(0, trimmed.length - 2).trim();
    }

    return trimmed;
  }

  static String normalizedPesoPrice(String value) {
    final trimmed = value.trim();
    return trimmed.startsWith('\u20B1') ? trimmed : '\u20B1$trimmed';
  }

  static String? validateForm({
    required bool hasImage,
    required String name,
    required String price,
    required String weight,
    required String? day,
    required String? month,
    required String? year,
    required String? category,
    required ProductProductionStage productionStage,
    required ProductSaleStatus sellingOption,
  }) {
    if (!hasImage) return 'Add a product photo.';
    if (name.isEmpty) return 'Enter the product name.';
    if (price.isEmpty) return 'Enter the price.';
    if (weight.isEmpty) return 'Enter the available weight.';
    final window = ProductAvailabilityDateRules.windowFor(
      productionStage: productionStage,
      sellingOption: sellingOption,
    );
    if (window.validationMessage(dateFor(day, month, year))
        case final message?) {
      return message;
    }
    if (category == null) return 'Select a category.';

    return null;
  }

  static FarmerDashboardProduct editedProduct({
    required FarmerDashboardProduct baseProduct,
    required String name,
    required String price,
    required String weight,
    required String? day,
    required String? month,
    required String? year,
    required String category,
    required String? imageAsset,
    required Uint8List? imageBytes,
    required String? imageUrl,
    required bool isSold,
    required ProductSaleStatus saleStatus,
    required ProductProductionStage productionStage,
  }) {
    final selectedDate =
        dateFor(day, month, year) ??
        ProductAvailabilityDateRules.philippineToday();
    final harvestDate =
        '${months[selectedDate.month - 1]} ${selectedDate.day}, '
        '${selectedDate.year}';
    return FarmerDashboardProduct(
      name: name,
      price: normalizedPesoPrice(price),
      unit: baseProduct.unit,
      harvestDate: harvestDate,
      category: category,
      imageAsset: imageAsset,
      imageBytes: imageBytes,
      imageUrl: imageUrl,
      availableWeight: '$weight ${baseProduct.unitType}',
      description: baseProduct.description,
      unitType: baseProduct.unitType,
      minimumOrderQuantity: baseProduct.minimumOrderQuantity,
      gradeQuality: baseProduct.gradeQuality,
      isOrganic: baseProduct.isOrganic,
      productionStatus: productionStage.databaseValue,
      saleStatus: saleStatus,
      isSold: isSold,
      commodityId: baseProduct.commodityId,
      farmId: baseProduct.farmId,
      inventoryDateType: baseProduct.inventoryDateType,
      harvestedAt: baseProduct.harvestedAt,
      sellUntil: baseProduct.sellUntil,
      expiresAt: baseProduct.expiresAt,
      lotCode: baseProduct.lotCode,
      storageInstructions: baseProduct.storageInstructions,
    );
  }

  static DateTime? dateFor(String? day, String? month, String? year) {
    final parsedDay = int.tryParse(day ?? '');
    final parsedMonth = months.indexOf(month ?? '') + 1;
    final parsedYear = int.tryParse(year ?? '');
    if (parsedDay == null || parsedMonth < 1 || parsedYear == null) return null;
    final date = DateTime(parsedYear, parsedMonth, parsedDay);
    return date.day == parsedDay && date.month == parsedMonth ? date : null;
  }
}
