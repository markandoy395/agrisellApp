class FarmerGcashDetails {
  const FarmerGcashDetails({
    required this.farmId,
    required this.farmerName,
    required this.accountName,
    required this.accountNumber,
  });

  factory FarmerGcashDetails.fromJson(Map<String, Object?> json) {
    return FarmerGcashDetails(
      farmId: _integer(json['farm_id']),
      farmerName: _text(json['farmer_name'], fallback: 'Farmer'),
      accountName: _text(json['account_name']),
      accountNumber: _text(json['account_number']),
    );
  }

  final int farmId;
  final String farmerName;
  final String accountName;
  final String accountNumber;

  bool get isComplete =>
      farmId > 0 && accountName.isNotEmpty && accountNumber.isNotEmpty;

  static String _text(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static int _integer(Object? value) => switch (value) {
    int number => number,
    num number => number.toInt(),
    String text => int.tryParse(text) ?? 0,
    _ => 0,
  };
}
