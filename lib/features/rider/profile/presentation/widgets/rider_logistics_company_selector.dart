import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';
import 'package:agresell_app/features/rider/profile/data/logistics_company_repository.dart';
import 'package:agresell_app/features/rider/profile/domain/logistics_company.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';

class RiderLogisticsCompanySelector extends StatefulWidget {
  const RiderLogisticsCompanySelector({required this.controller, super.key});

  final RiderSignUpController controller;

  @override
  State<RiderLogisticsCompanySelector> createState() =>
      _RiderLogisticsCompanySelectorState();
}

class _RiderLogisticsCompanySelectorState
    extends State<RiderLogisticsCompanySelector> {
  final _repository = const LogisticsCompanyRepository();
  late Future<List<LogisticsCompany>> _companies;

  @override
  void initState() {
    super.initState();
    _companies = _repository.loadAvailable();
  }

  void _reload() => setState(() => _companies = _repository.loadAvailable());

  @override
  Widget build(BuildContext context) => FutureBuilder<List<LogisticsCompany>>(
    future: _companies,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: LinearProgressIndicator(),
        );
      }
      if (snapshot.hasError) {
        return _message(
          'Logistics companies could not be loaded. You can register without one and be assigned later.',
          retry: _reload,
        );
      }
      final companies = snapshot.data ?? const <LogisticsCompany>[];
      if (companies.isEmpty) {
        return _message(
          'No active logistics companies are available yet. You can register as an independent rider.',
          retry: _reload,
        );
      }
      final selectedId = widget.controller.draft.value(
        RiderSignUpFields.logisticsCompanyId,
      );
      final availableIds = companies.map((company) => company.id).toSet();
      final value = availableIds.contains(selectedId) ? selectedId : '';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            dropdownColor: AppDropdownStyle.menuColor,
            borderRadius: AppDropdownStyle.menuBorderRadius,
            style: AppDropdownStyle.textStyle,
            iconEnabledColor: AppDropdownStyle.iconColor,
            key: ValueKey(value),
            initialValue: value,
            isExpanded: true,
            decoration: AuthInputStyle.decoration(
              label: 'Logistics company (optional)',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 16,
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: '',
                child: Text('Independent rider / assign later'),
              ),
              ...companies.map(
                (company) => DropdownMenuItem(
                  value: company.id,
                  child: Text(company.name),
                ),
              ),
            ],
            onChanged: (id) {
              final selected = companies
                  .where((company) => company.id == id)
                  .firstOrNull;
              widget.controller.updateValue(
                RiderSignUpFields.logisticsCompanyId,
                id ?? '',
              );
              widget.controller.updateValue(
                RiderSignUpFields.logisticsCompanyName,
                selected?.name ?? '',
              );
            },
          ),
          const SizedBox(height: 5),
          const Text(
            'Only active partners are shown. Your selection is verified when the application is submitted.',
            style: SharedPresentationStyles.mutedCaption,
          ),
        ],
      );
    },
  );

  Widget _message(String text, {required VoidCallback retry}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: SharedPresentationStyles.borderedField,
    child: Row(
      children: [
        const Icon(Icons.local_shipping_outlined, size: 18),
        const SizedBox(width: 9),
        Expanded(child: Text(text, style: SharedPresentationStyles.caption)),
        IconButton(
          tooltip: 'Retry',
          onPressed: retry,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
  );
}
