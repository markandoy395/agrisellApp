import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';

import 'rider_withdrawal_method_form.dart';
import 'rider_withdrawal_method_list.dart';
import 'rider_withdrawal_sheet_layout.dart';

class RiderWithdrawalMethodsSheet extends StatefulWidget {
  const RiderWithdrawalMethodsSheet({
    required this.riderId,
    required this.controller,
    super.key,
  });

  final String riderId;
  final RiderAnalyticsController controller;

  @override
  State<RiderWithdrawalMethodsSheet> createState() =>
      _RiderWithdrawalMethodsSheetState();
}

class _RiderWithdrawalMethodsSheetState
    extends State<RiderWithdrawalMethodsSheet> {
  bool _isAdding = false;
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  String _payoutMethod = 'gcash';
  bool _isDefault = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    widget.controller.loadWithdrawalMethods(riderId: widget.riderId);
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  Future<void> _saveMethod() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await widget.controller.saveWithdrawalMethod(
        riderId: widget.riderId,
        method: RiderWithdrawalMethod(
          methodId: '',
          payoutMethod: _payoutMethod,
          accountName: _accountNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          bankName: _payoutMethod == 'bank_transfer'
              ? _bankNameController.text.trim()
              : '',
          isDefault: _isDefault,
        ),
      );
      if (!mounted) return;
      setState(() {
        _isAdding = false;
        _isSaving = false;
        _accountNameController.clear();
        _accountNumberController.clear();
        _bankNameController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(content: Text('Failed to save withdrawal method: $e')),
      );
    }
  }

  Future<void> _deleteMethod(String methodId) async {
    try {
      await widget.controller.deleteWithdrawalMethod(
        riderId: widget.riderId,
        methodId: methodId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(SnackBar(content: Text('Failed to delete method: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => RiderWithdrawalSheetLayout(
        child: _isAdding
            ? RiderWithdrawalMethodForm(
                formKey: _formKey,
                accountNameController: _accountNameController,
                accountNumberController: _accountNumberController,
                bankNameController: _bankNameController,
                payoutMethod: _payoutMethod,
                isDefault: _isDefault,
                isSaving: _isSaving,
                onPayoutMethodChanged: (method) =>
                    setState(() => _payoutMethod = method),
                onDefaultChanged: (value) => setState(() => _isDefault = value),
                onCancel: () => setState(() => _isAdding = false),
                onSave: _saveMethod,
              )
            : RiderWithdrawalMethodList(
                methods: widget.controller.withdrawalMethods,
                onDelete: _deleteMethod,
                onAdd: () => setState(() => _isAdding = true),
              ),
      ),
    );
  }
}
