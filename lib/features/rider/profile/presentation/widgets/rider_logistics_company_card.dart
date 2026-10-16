import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_safe_scaffold.dart';
import 'package:agresell_app/features/rider/profile/data/logistics_company_repository.dart';
import 'package:agresell_app/features/rider/profile/domain/logistics_company.dart';
import '../styles/rider_profile_design_styles.dart';
import 'rider_profile_design_components.dart';
import 'rider_profile_empty_state.dart';

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
    if (widget.companyId == null)
      return RiderProfileSection(
        title: 'Logistics partner',
        icon: Icons.local_shipping_outlined,
        children: [
          Text(
            'No logistics company assigned',
            style: RiderProfileDesignStyles.body,
          ),
          const SizedBox(height: 6),
          Text(
            'You can still receive assignments when approved.',
            style: RiderProfileDesignStyles.muted,
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              agrisellPageRoute<void>(
                builder: (_) => Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(appBarTheme: RiderProfileDesignStyles.appBar),
                  child: RiderSafeScaffold(
                    backgroundColor: RiderProfileDesignStyles.background,
                    appBar: AppBar(title: const Text('Logistics partner')),
                    body: const RiderProfileEmptyState(logistics: true),
                  ),
                ),
              ),
            ),
            child: const Text('View partner status'),
          ),
        ],
      );
    return FutureBuilder<LogisticsCompany?>(
      future: _company,
      builder: (context, snapshot) {
        final company = snapshot.data;
        return RiderProfileSection(
          title: 'Logistics partner',
          icon: Icons.local_shipping_outlined,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator()
            else if (company == null)
              Text(
                'Partner record is unavailable. Please contact support.',
                style: RiderProfileDesignStyles.muted,
              )
            else ...[
              RiderProfileDetailRow(
                icon: Icons.business_outlined,
                label: company.name,
                value: company.serviceAreaLabel,
              ),
              if (company.contactNumber.isNotEmpty)
                RiderProfileDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Contact number',
                  value: company.contactNumber,
                ),
              Row(
                children: [
                  Icon(
                    company.codAvailable
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    color: AgrisellColors.authGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      company.codAvailable
                          ? 'Cash on delivery supported'
                          : 'No cash on delivery',
                      style: RiderProfileDesignStyles.muted,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
