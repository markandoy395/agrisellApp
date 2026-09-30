class FarmerVerificationDetails {
  const FarmerVerificationDetails({
    this.farmerUserId,
    this.verificationStatus,
    this.accountStatus,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    this.farmId,
    this.farmName,
    this.farmAddress,
    this.barangay,
    this.city,
    this.province,
    this.farmImages = const [],
    this.action,
    this.reason,
    this.message,
    this.missingItems = const [],
    this.reviewedAt,
    this.hasInformationRequest = false,
    this.requestId,
    this.requestedBy,
    this.requestedAt,
  });

  final int? farmerUserId;
  final String? verificationStatus;
  final String? accountStatus;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final int? farmId;
  final String? farmName;
  final String? farmAddress;
  final String? barangay;
  final String? city;
  final String? province;
  final List<String> farmImages;
  final String? action;
  final String? reason;
  final String? message;
  final List<String> missingItems;
  final DateTime? reviewedAt;
  final bool hasInformationRequest;
  final int? requestId;
  final String? requestedBy;
  final DateTime? requestedAt;

  bool get isNeedsInformation =>
      action == 'needs_information' ||
      hasInformationRequest ||
      verificationStatus?.trim().toLowerCase() == 'needs_information';

  bool get isPending =>
      !isNeedsInformation &&
      !isRejected &&
      (verificationStatus?.trim().toLowerCase() == 'pending' ||
          verificationStatus == null);

  bool get isVerified =>
      verificationStatus?.trim().toLowerCase() == 'verified' ||
      action == 'verified';

  bool get isRejected =>
      verificationStatus?.trim().toLowerCase() == 'rejected' ||
      action == 'rejected';

  bool get hasMessage => message != null && message!.trim().isNotEmpty;

  bool get hasMissingItems => missingItems.isNotEmpty;

  String get formattedRequestedDate {
    final date = requestedAt ?? reviewedAt;
    if (date == null) return 'Recently';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  factory FarmerVerificationDetails.fromJson(Map<String, dynamic> json) {
    final rawMissing = json['missing_items'];
    final missingItems = <String>[];
    if (rawMissing is List) {
      for (final item in rawMissing) {
        if (item != null) {
          final s = item.toString().trim();
          if (s.isNotEmpty) missingItems.add(s);
        }
      }
    }

    final rawImages = json['farm_images'];
    final farmImages = <String>[];
    if (rawImages is List) {
      for (final item in rawImages) {
        if (item != null) {
          final s = item.toString().trim();
          if (s.isNotEmpty) farmImages.add(s);
        }
      }
    }

    final rawFarmerId = json['farmer_user_id'];
    final farmerUserId = rawFarmerId is int
        ? rawFarmerId
        : int.tryParse(rawFarmerId?.toString() ?? '');

    final rawFarmId = json['farm_id'];
    final farmId = rawFarmId is int
        ? rawFarmId
        : int.tryParse(rawFarmId?.toString() ?? '');

    final rawReqId = json['request_id'];
    final requestId = rawReqId is int
        ? rawReqId
        : int.tryParse(rawReqId?.toString() ?? '');

    return FarmerVerificationDetails(
      farmerUserId: farmerUserId,
      verificationStatus: json['verification_status']?.toString(),
      accountStatus: json['account_status']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      farmId: farmId,
      farmName: json['farm_name']?.toString(),
      farmAddress: json['farm_address']?.toString(),
      barangay: json['barangay']?.toString(),
      city: json['city']?.toString(),
      province: json['province']?.toString(),
      farmImages: List.unmodifiable(farmImages),
      action: json['action']?.toString(),
      reason: json['reason']?.toString(),
      message: json['message']?.toString(),
      missingItems: List.unmodifiable(missingItems),
      reviewedAt: DateTime.tryParse(json['reviewed_at']?.toString() ?? ''),
      hasInformationRequest: json['has_information_request'] == true,
      requestId: requestId,
      requestedBy: json['requested_by']?.toString(),
      requestedAt: DateTime.tryParse(json['requested_at']?.toString() ?? ''),
    );
  }
}
