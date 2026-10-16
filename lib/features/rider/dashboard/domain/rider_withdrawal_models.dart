class RiderWithdrawalMethod {
  const RiderWithdrawalMethod({
    required this.methodId,
    required this.payoutMethod, // 'gcash' or 'bank_transfer'
    required this.accountName,
    required this.accountNumber,
    this.bankName = '',
    this.isDefault = true,
    this.createdAt,
  });

  factory RiderWithdrawalMethod.fromJson(Map<String, Object?> json) {
    return RiderWithdrawalMethod(
      methodId: json['methodId']?.toString() ?? '',
      payoutMethod: json['payoutMethod']?.toString() ?? 'gcash',
      accountName: json['accountName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      isDefault: json['isDefault'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  final String methodId;
  final String payoutMethod;
  final String accountName;
  final String accountNumber;
  final String bankName;
  final bool isDefault;
  final DateTime? createdAt;

  bool get isGcash => payoutMethod == 'gcash';
  bool get isBank => payoutMethod == 'bank_transfer';

  String get methodLabel =>
      isGcash ? 'GCash' : (bankName.isNotEmpty ? bankName : 'Bank Transfer');

  Map<String, Object?> toJson() => {
    'methodId': methodId,
    'payoutMethod': payoutMethod,
    'accountName': accountName,
    'accountNumber': accountNumber,
    'bankName': bankName,
    'isDefault': isDefault,
    'createdAt': createdAt?.toIso8601String(),
  };
}

class RiderWithdrawalRequest {
  const RiderWithdrawalRequest({
    required this.requestId,
    required this.amount,
    required this.payoutMethod,
    required this.accountName,
    required this.accountNumber,
    this.bankName = '',
    this.status = 'pending',
    this.notes = '',
    this.rejectionReason = '',
    this.createdAt,
    this.withdrawalMethodId,
    this.payoutReference = '',
  });

  factory RiderWithdrawalRequest.fromJson(Map<String, Object?> json) {
    return RiderWithdrawalRequest(
      requestId: json['requestId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      payoutMethod: json['payoutMethod']?.toString() ?? 'gcash',
      accountName: json['accountName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      payoutReference: json['payoutReference']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      rejectionReason: json['rejectionReason']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  final String requestId;
  final String? withdrawalMethodId;
  final String payoutReference;
  final double amount;
  final String payoutMethod;
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String status;
  final String notes;
  final String rejectionReason;
  final DateTime? createdAt;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isPaid => status == 'paid';
  bool get isRejected => status == 'rejected';

  String get methodLabel =>
      payoutMethod == 'bank_transfer' ? 'Bank Transfer' : 'GCash';

  String get statusLabel => switch (status.toLowerCase()) {
    'paid' => 'Paid',
    'approved' => 'Approved',
    'rejected' => 'Rejected',
    _ => 'Pending Approval',
  };

  Map<String, Object?> toJson() => {
    'requestId': requestId,
    'amount': amount,
    'payoutMethod': payoutMethod,
    'accountName': accountName,
    'accountNumber': accountNumber,
    'bankName': bankName,
    'status': status,
    'notes': notes,
    'rejectionReason': rejectionReason,
    'createdAt': createdAt?.toIso8601String(),
  };
}
