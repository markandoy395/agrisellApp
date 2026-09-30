class DealVoucher {
  const DealVoucher({
    required this.saleId,
    required this.name,
    this.code,
    required this.discountType,
    required this.discountValue,
    this.targetUserGroup = 'all_users',
    this.startsAt,
    this.endsAt,
    this.farmId,
    this.farmName,
    this.productCount = 0,
    this.featuredCommodityNames = const [],
    this.featuredImageUrls = const [],
    this.promoteOnHome = false,
  });

  final int saleId;
  final String name;
  final String? code;
  final String discountType;
  final double discountValue;
  final String targetUserGroup;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? farmId;
  final String? farmName;
  final int productCount;
  final List<String> featuredCommodityNames;
  final List<String> featuredImageUrls;
  final bool promoteOnHome;

  bool get hasCode => code != null && code!.trim().isNotEmpty;

  bool get isNewUsersOnly =>
      targetUserGroup.toLowerCase().trim() == 'new_users_only';

  bool get isFarmerDeal => farmId != null;

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

  String get formattedExpiry {
    if (endsAt == null) return 'No expiration';
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
    return 'Valid until ${months[endsAt!.month - 1]} ${endsAt!.day}, ${endsAt!.year}';
  }

  bool isExpiredAt(DateTime now) {
    if (endsAt == null) return false;
    return endsAt!.isBefore(now);
  }

  factory DealVoucher.fromRow(Map<String, dynamic> row) {
    final rawSaleId = row['sale_id'];
    final saleId = rawSaleId is int
        ? rawSaleId
        : int.tryParse(rawSaleId?.toString() ?? '') ?? 0;

    final rawFarmId = row['farm_id'];
    final farmId = rawFarmId is int
        ? rawFarmId
        : int.tryParse(rawFarmId?.toString() ?? '');

    final rawProdCount = row['product_count'];
    final productCount = rawProdCount is int
        ? rawProdCount
        : int.tryParse(rawProdCount?.toString() ?? '') ?? 0;

    final rawNames = row['featured_commodity_names'];
    final commodityNames = rawNames is List
        ? rawNames.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    final rawImages = row['featured_image_urls'];
    final imageUrls = rawImages is List
        ? rawImages.map((e) => e.toString()).toList(growable: false)
        : const <String>[];

    return DealVoucher(
      saleId: saleId,
      name: row['name']?.toString() ?? 'Deal',
      code: row['promo_code']?.toString(),
      discountType: row['discount_type']?.toString() ?? 'percentage',
      discountValue: (row['discount_value'] as num?)?.toDouble() ?? 0.0,
      targetUserGroup: row['target_user_group']?.toString() ?? 'all_users',
      startsAt: DateTime.tryParse(row['starts_at']?.toString() ?? ''),
      endsAt: DateTime.tryParse(row['ends_at']?.toString() ?? ''),
      farmId: farmId,
      farmName: row['farm_name']?.toString(),
      productCount: productCount,
      featuredCommodityNames: commodityNames,
      featuredImageUrls: imageUrls,
      promoteOnHome: row['promote_on_home'] == true,
    );
  }
}
