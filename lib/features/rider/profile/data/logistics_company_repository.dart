import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/profile/domain/logistics_company.dart';

class LogisticsCompanyRepository {
  const LogisticsCompanyRepository();

  Future<List<LogisticsCompany>> loadAvailable() async {
    if (!AgrisellSupabase.isInitialized) return const [];
    final response = await AgrisellSupabase.client
        .from('logistics_companies')
        .select(
          'logistics_company_id, company_name, contact_person, '
          'contact_number, email, service_areas, pricing_model, '
          'cod_available, rating, status',
        )
        .order('company_name');
    return (response as List)
        .whereType<Map>()
        .map(_companyFromRow)
        .where((company) => company.isAvailable)
        .toList(growable: false);
  }

  Future<LogisticsCompany?> findById(String companyId) async {
    if (!AgrisellSupabase.isInitialized || companyId.trim().isEmpty) {
      return null;
    }
    final response = await AgrisellSupabase.client
        .from('logistics_companies')
        .select(
          'logistics_company_id, company_name, contact_person, '
          'contact_number, email, service_areas, pricing_model, '
          'cod_available, rating, status',
        )
        .eq('logistics_company_id', companyId)
        .maybeSingle();
    return response == null ? null : _companyFromRow(response);
  }
}

LogisticsCompany _companyFromRow(Map row) => LogisticsCompany.fromJson({
  for (final entry in row.entries) '${entry.key}': entry.value,
});
