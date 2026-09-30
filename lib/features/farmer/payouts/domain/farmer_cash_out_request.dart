class FarmerCashOutRequest {
  const FarmerCashOutRequest({
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
  });

  factory FarmerCashOutRequest.fromJson(Map<String, Object?> json) {
    return FarmerCashOutRequest(
      requestId: json['requestId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      payoutMethod: json['payoutMethod']?.toString() ?? 'gcash',
      accountName: json['accountName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      notes: json['notes']?.toString() ?? '',
      rejectionReason: json['rejectionReason']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  final String requestId;
  final double amount;
  final String payoutMethod; // 'gcash' or 'bank_transfer'
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String status; // 'pending', 'approved', 'rejected', 'paid'
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
