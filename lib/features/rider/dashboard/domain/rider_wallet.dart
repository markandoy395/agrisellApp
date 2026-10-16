class RiderWallet {
  const RiderWallet({
    this.available = 0,
    this.reserved = 0,
    this.paid = 0,
    this.reconciliationRequired = false,
  });

  factory RiderWallet.fromJson(Map<String, Object?> json) => RiderWallet(
    available: (json['available'] as num).toDouble(),
    reserved: (json['reserved'] as num).toDouble(),
    paid: (json['paid'] as num).toDouble(),
    reconciliationRequired: json['reconciliation_required'] == true,
  );

  final double available;
  final double reserved;
  final double paid;
  final bool reconciliationRequired;
}

abstract interface class RiderWalletRepository {
  Future<RiderWallet> fetchWallet();
}
