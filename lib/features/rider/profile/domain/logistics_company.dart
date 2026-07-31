class LogisticsCompany {
  const LogisticsCompany({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.contactNumber,
    required this.email,
    required this.serviceAreas,
    required this.pricingModel,
    required this.codAvailable,
    required this.rating,
    required this.status,
  });

  factory LogisticsCompany.fromJson(Map<String, Object?> json) =>
      LogisticsCompany(
        id: _text(json['logistics_company_id']),
        name: _text(json['company_name']),
        contactPerson: _text(json['contact_person']),
        contactNumber: _text(json['contact_number']),
        email: _text(json['email']),
        serviceAreas: _textList(json['service_areas']),
        pricingModel: _text(json['pricing_model']),
        codAvailable: json['cod_available'] as bool? ?? false,
        rating: _number(json['rating']),
        status: _text(json['status']),
      );

  final String id;
  final String name;
  final String contactPerson;
  final String contactNumber;
  final String email;
  final List<String> serviceAreas;
  final String pricingModel;
  final bool codAvailable;
  final double rating;
  final String status;

  /// Empty legacy statuses are treated as active, so existing company rows
  /// remain usable until their administrator explicitly deactivates them.
  bool get isAvailable {
    final normalized = status.trim().toLowerCase();
    return normalized.isEmpty || normalized == 'active';
  }

  String get serviceAreaLabel => serviceAreas.isEmpty
      ? 'Service areas not listed'
      : serviceAreas.join(', ');
}

String _text(Object? value) => value?.toString().trim() ?? '';

double _number(Object? value) =>
    value is num ? value.toDouble() : double.tryParse(_text(value)) ?? 0;

List<String> _textList(Object? value) => value is List
    ? value.map(_text).where((item) => item.isNotEmpty).toList()
    : const [];
