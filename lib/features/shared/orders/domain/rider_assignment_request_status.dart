enum RiderAssignmentRequestStatus {
  pending,
  accepted,
  declined,
  expired,
  cancelled,
  failed;

  factory RiderAssignmentRequestStatus.fromValue(Object? value) {
    final name = value?.toString().trim().toLowerCase();
    return RiderAssignmentRequestStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => RiderAssignmentRequestStatus.failed,
    );
  }

  String get label => switch (this) {
    RiderAssignmentRequestStatus.pending => 'Pending rider response',
    RiderAssignmentRequestStatus.accepted => 'Accepted',
    RiderAssignmentRequestStatus.declined => 'Declined',
    RiderAssignmentRequestStatus.expired => 'Expired',
    RiderAssignmentRequestStatus.cancelled => 'Cancelled',
    RiderAssignmentRequestStatus.failed => 'Failed',
  };

  bool get isPending => this == RiderAssignmentRequestStatus.pending;
  bool get allowsAnotherRequest => switch (this) {
    RiderAssignmentRequestStatus.declined ||
    RiderAssignmentRequestStatus.expired ||
    RiderAssignmentRequestStatus.cancelled ||
    RiderAssignmentRequestStatus.failed => true,
    RiderAssignmentRequestStatus.pending ||
    RiderAssignmentRequestStatus.accepted => false,
  };
}
