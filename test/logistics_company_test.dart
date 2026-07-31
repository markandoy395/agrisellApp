import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/profile/domain/logistics_company.dart';

void main() {
  test('maps an active logistics company and its delivery capabilities', () {
    final company = LogisticsCompany.fromJson({
      'logistics_company_id': 42,
      'company_name': 'Agri Express',
      'contact_person': 'Mia Santos',
      'contact_number': '09171234567',
      'email': 'dispatch@example.com',
      'service_areas': ['Butuan', 'Cabadbaran'],
      'pricing_model': 'Distance based',
      'cod_available': true,
      'rating': 4.8,
      'status': 'active',
    });

    expect(company.id, '42');
    expect(company.isAvailable, isTrue);
    expect(company.serviceAreaLabel, 'Butuan, Cabadbaran');
    expect(company.codAvailable, isTrue);
  });

  test('does not offer an inactive logistics company for selection', () {
    final company = LogisticsCompany.fromJson({
      'logistics_company_id': 7,
      'company_name': 'Paused Courier',
      'status': 'inactive',
    });

    expect(company.isAvailable, isFalse);
  });
}
