enum OrderDisputeStatus {
  pending,
  resolved,
  rejected;

  static OrderDisputeStatus fromValue(Object? value) {
    return switch (value?.toString().toLowerCase()) {
      'resolved' => OrderDisputeStatus.resolved,
      'rejected' => OrderDisputeStatus.rejected,
      _ => OrderDisputeStatus.pending,
    };
  }

  String get label => switch (this) {
    OrderDisputeStatus.pending => 'Under review',
    OrderDisputeStatus.resolved => 'Resolved',
    OrderDisputeStatus.rejected => 'Rejected',
  };
}

enum OrderDisputeCategory {
  damagedRottenProduce,
  missingItems,
  wrongItems,
  qualityMismatch,
  other;

  static OrderDisputeCategory fromValue(Object? value) {
    final text = value?.toString().toLowerCase().replaceAll('-', '_') ?? '';
    if (text.contains('damaged') || text.contains('rotten')) {
      return OrderDisputeCategory.damagedRottenProduce;
    }
    if (text.contains('missing')) return OrderDisputeCategory.missingItems;
    if (text.contains('wrong')) return OrderDisputeCategory.wrongItems;
    if (text.contains('quality') || text.contains('grade')) {
      return OrderDisputeCategory.qualityMismatch;
    }
    return OrderDisputeCategory.other;
  }

  String get value => switch (this) {
    OrderDisputeCategory.damagedRottenProduce => 'damaged_rotten_produce',
    OrderDisputeCategory.missingItems => 'missing_items',
    OrderDisputeCategory.wrongItems => 'wrong_items',
    OrderDisputeCategory.qualityMismatch => 'quality_mismatch',
    OrderDisputeCategory.other => 'other',
  };

  String get label => switch (this) {
    OrderDisputeCategory.damagedRottenProduce => 'Damaged / Rotten Produce',
    OrderDisputeCategory.missingItems => 'Missing Items / Incomplete Order',
    OrderDisputeCategory.wrongItems => 'Incorrect Items Received',
    OrderDisputeCategory.qualityMismatch => 'Quality / Specification Mismatch',
    OrderDisputeCategory.other => 'Other Issue',
  };
}

enum OrderDisputeResolution {
  fullRefund,
  partialRefund,
  replacement,
  other;

  static OrderDisputeResolution fromValue(Object? value) {
    final text = value?.toString().toLowerCase().replaceAll('-', '_') ?? '';
    if (text.contains('full')) return OrderDisputeResolution.fullRefund;
    if (text.contains('partial')) return OrderDisputeResolution.partialRefund;
    if (text.contains('replace')) return OrderDisputeResolution.replacement;
    return OrderDisputeResolution.other;
  }

  String get value => switch (this) {
    OrderDisputeResolution.fullRefund => 'full_refund',
    OrderDisputeResolution.partialRefund => 'partial_refund',
    OrderDisputeResolution.replacement => 'replacement',
    OrderDisputeResolution.other => 'other',
  };

  String get label => switch (this) {
    OrderDisputeResolution.fullRefund => 'Full Refund',
    OrderDisputeResolution.partialRefund => 'Partial Refund',
    OrderDisputeResolution.replacement => 'Replacement / Resend',
    OrderDisputeResolution.other => 'Other Resolution',
  };
}

class OrderDispute {
  const OrderDispute({
    required this.status,
    required this.category,
    required this.reason,
    required this.requestedResolution,
    this.submittedAt,
    this.resolvedAt,
    this.resolutionNote,
  });

  final OrderDisputeStatus status;
  final OrderDisputeCategory category;
  final String reason;
  final OrderDisputeResolution requestedResolution;
  final DateTime? submittedAt;
  final DateTime? resolvedAt;
  final String? resolutionNote;

  bool get isPending => status == OrderDisputeStatus.pending;
  bool get isResolved => status == OrderDisputeStatus.resolved;
  bool get isRejected => status == OrderDisputeStatus.rejected;

  OrderDispute copyWith({
    OrderDisputeStatus? status,
    OrderDisputeCategory? category,
    String? reason,
    OrderDisputeResolution? requestedResolution,
    DateTime? submittedAt,
    DateTime? resolvedAt,
    String? resolutionNote,
  }) {
    return OrderDispute(
      status: status ?? this.status,
      category: category ?? this.category,
      reason: reason ?? this.reason,
      requestedResolution: requestedResolution ?? this.requestedResolution,
      submittedAt: submittedAt ?? this.submittedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNote: resolutionNote ?? this.resolutionNote,
    );
  }

  Map<String, Object?> toJson() => {
    'status': status.name,
    'category': category.value,
    'reason': reason,
    'requestedResolution': requestedResolution.value,
    if (submittedAt != null) 'submittedAt': submittedAt!.toIso8601String(),
    if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
    if (resolutionNote != null) 'resolutionNote': resolutionNote,
  };

  factory OrderDispute.fromJson(Map<String, Object?> json) {
    return OrderDispute(
      status: OrderDisputeStatus.fromValue(json['status']),
      category: OrderDisputeCategory.fromValue(json['category']),
      reason: json['reason']?.toString() ?? '',
      requestedResolution: OrderDisputeResolution.fromValue(
        json['requestedResolution'],
      ),
      submittedAt: DateTime.tryParse(json['submittedAt']?.toString() ?? ''),
      resolvedAt: DateTime.tryParse(json['resolvedAt']?.toString() ?? ''),
      resolutionNote: json['resolutionNote']?.toString(),
    );
  }
}
