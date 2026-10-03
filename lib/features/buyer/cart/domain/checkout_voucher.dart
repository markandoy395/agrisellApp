class AppliedVoucher {
  const AppliedVoucher({
    required this.saleId,
    required this.name,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.targetUserGroup,
    required this.discountAmount,
    required this.applicableCommodityIds,
  });

  final String saleId;
  final String name;
  final String code;
  final String discountType;
  final double discountValue;
  final String targetUserGroup;
  final double discountAmount;
  final Set<int> applicableCommodityIds;

  String get discountLabel {
    if (discountType == 'percentage') {
      final formatted = discountValue.toStringAsFixed(
        discountValue.truncateToDouble() == discountValue ? 0 : 2,
      );
      return '$formatted% OFF';
    }
    return '\u20b1${discountValue.toStringAsFixed(2)} OFF';
  }

  AppliedVoucher copyWithAmount(double newAmount) => AppliedVoucher(
    saleId: saleId,
    name: name,
    code: code,
    discountType: discountType,
    discountValue: discountValue,
    targetUserGroup: targetUserGroup,
    discountAmount: newAmount,
    applicableCommodityIds: applicableCommodityIds,
  );
}

class VoucherValidationException implements Exception {
  const VoucherValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}
