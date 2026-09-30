class FarmerDiscount {
  const FarmerDiscount({
    required this.saleId,
    required this.farmId,
    required this.name,
    required this.discountType,
    required this.discountValue,
    this.startsAt,
    this.endsAt,
    this.promoCode,
    this.isEnabled = true,
    this.createdAt,
    this.commodityIds = const [],
    this.commodities = const [],
  });

  final int saleId;
  final int farmId;
  final String name;
  final String discountType;
  final double discountValue;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? promoCode;
  final bool isEnabled;
  final DateTime? createdAt;
  final List<int> commodityIds;
  final List<Map<String, dynamic>> commodities;

  bool get hasCode => promoCode != null && promoCode!.trim().isNotEmpty;

  String get discountLabel {
    if (discountType == 'percentage') {
      final formatted = discountValue.toStringAsFixed(
        discountValue.truncateToDouble() == discountValue ? 0 : 2,
      );
      return '$formatted% OFF';
    }
    if (discountType == 'sale_price') {
      final formatted = discountValue.toStringAsFixed(
        discountValue.truncateToDouble() == discountValue ? 0 : 2,
      );
      return '\u20b1$formatted Fixed';
    }
    final formatted = discountValue.toStringAsFixed(
      discountValue.truncateToDouble() == discountValue ? 0 : 2,
    );
    return '\u20b1$formatted OFF';
  }

  String get status {
    if (!isEnabled) return 'Disabled';
    final now = DateTime.now();
    if (startsAt != null && startsAt!.isAfter(now)) return 'Scheduled';
    if (endsAt != null && endsAt!.isBefore(now)) return 'Ended';
    return 'Active';
  }

  bool get isActive => status == 'Active';
  bool get isScheduled => status == 'Scheduled';
  bool get isEnded => status == 'Ended';

  String get formattedDates {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    String formatDate(DateTime dt) =>
        '${months[dt.month - 1]} ${dt.day}, ${dt.year}';

    if (startsAt != null && endsAt != null) {
      return '${formatDate(startsAt!)} - ${formatDate(endsAt!)}';
    }
    if (startsAt != null) {
      return 'Starts ${formatDate(startsAt!)}';
    }
    if (endsAt != null) {
      return 'Ends ${formatDate(endsAt!)}';
    }
    return 'Ongoing';
  }

  factory FarmerDiscount.fromRow(Map<String, dynamic> row) {
    final rawSaleId = row['sale_id'];
    final saleId = rawSaleId is int
        ? rawSaleId
        : int.tryParse(rawSaleId?.toString() ?? '') ?? 0;

    final rawFarmId = row['farm_id'];
    final farmId = rawFarmId is int
        ? rawFarmId
        : int.tryParse(rawFarmId?.toString() ?? '') ?? 0;

    final rawCommodities = row['commodities'];
    final commoditiesList = rawCommodities is List
        ? rawCommodities.whereType<Map<String, dynamic>>().toList(growable: false)
        : const <Map<String, dynamic>>[];

    final commodityIds = commoditiesList
        .map((c) => int.tryParse(c['commodity_id']?.toString() ?? ''))
        .whereType<int>()
        .toList(growable: false);

    return FarmerDiscount(
      saleId: saleId,
      farmId: farmId,
      name: row['name']?.toString() ?? 'Promotion',
      discountType: row['discount_type']?.toString() ?? 'percentage',
      discountValue: (row['discount_value'] as num?)?.toDouble() ?? 0.0,
      startsAt: DateTime.tryParse(row['starts_at']?.toString() ?? ''),
      endsAt: DateTime.tryParse(row['ends_at']?.toString() ?? ''),
      promoCode: row['promo_code']?.toString(),
      isEnabled: row['is_enabled'] != false,
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? ''),
      commodityIds: commodityIds,
      commodities: commoditiesList,
    );
  }
}
