import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/profile/data/logistics_company_repository.dart';
import 'package:agresell_app/features/rider/profile/domain/logistics_company.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_components.dart';

class RiderLogisticsCompanyCard extends StatefulWidget {
  const RiderLogisticsCompanyCard({required this.companyId, super.key});

  final String? companyId;

  @override
  State<RiderLogisticsCompanyCard> createState() =>
      _RiderLogisticsCompanyCardState();
}

class _RiderLogisticsCompanyCardState extends State<RiderLogisticsCompanyCard> {
  final _repository = const LogisticsCompanyRepository();
  Future<LogisticsCompany?>? _company;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant RiderLogisticsCompanyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.companyId != widget.companyId) _load();
  }

  void _load() {
    final id = widget.companyId;
    _company = id == null ? null : _repository.findById(id);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.companyId == null) return _unassignedCard();
    return FutureBuilder<LogisticsCompany?>(
      future: _company,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const RiderProfileInformationCard(
            title: 'Logistics partner',
            rows: [
              RiderProfileInfoRow(
                Icons.business_outlined,
                'Loading partner details…',
              ),
            ],
          );
        }
        final company = snapshot.data;
        if (company == null) {
          return const RiderProfileInformationCard(
            title: 'Logistics partner',
            rows: [
              RiderProfileInfoRow(
                Icons.business_outlined,
                'Partner record is unavailable. Please contact support.',
              ),
            ],
          );
        }
        return RiderProfileInformationCard(
          title: 'Logistics partner',
          rows: [
            RiderProfileInfoRow(Icons.business_outlined, company.name),
            RiderProfileInfoRow(Icons.map_outlined, company.serviceAreaLabel),
            RiderProfileInfoRow(
              Icons.payments_outlined,
              company.codAvailable
                  ? 'Cash on delivery supported'
                  : 'No cash on delivery',
            ),
            if (company.contactNumber.isNotEmpty)
              RiderProfileInfoRow(Icons.phone_outlined, company.contactNumber),
          ],
        );
      },
    );
  }

  Widget _unassignedCard() => const RiderProfileInformationCard(
    title: 'Logistics partner',
    rows: [
      RiderProfileInfoRow(
        Icons.business_outlined,
        'No logistics company assigned. You can still receive assignments when approved.',
      ),
    ],
  );
}
