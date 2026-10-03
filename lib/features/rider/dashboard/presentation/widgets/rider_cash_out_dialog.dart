import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import '../styles/rider_cash_out_dialog_styles.dart';
import 'rider_cash_out_amount_field.dart';
import 'rider_cash_out_balance_card.dart';
import 'rider_cash_out_destination_picker.dart';
import 'rider_cash_out_form_controls.dart';
import 'rider_cash_out_header.dart';

class RiderCashOutDialog extends StatefulWidget {
  const RiderCashOutDialog({
    required this.riderId,
    required this.controller,
    required this.availableEarnings,
    super.key,
  });

  final String riderId;
  final RiderAnalyticsController controller;
  final double availableEarnings;

  @override
  State<RiderCashOutDialog> createState() => _RiderCashOutDialogState();
}

class _RiderCashOutDialogState extends State<RiderCashOutDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  final _notesController = TextEditingController();

  RiderWithdrawalMethod? _selectedMethod;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _initMethods();
  }

  void _initMethods() {
    final methods = widget.controller.withdrawalMethods;
    if (methods.isNotEmpty) {
      _selectedMethod =
          methods.firstWhere((m) => m.isDefault, orElse: () => methods.first);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(0);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMethod == null) {
      setState(() => _errorMessage = 'Please select a withdrawal method.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final request = RiderWithdrawalRequest(
      requestId: '',
      amount: amount,
      payoutMethod: _selectedMethod!.payoutMethod,
      accountName: _selectedMethod!.accountName,
      accountNumber: _selectedMethod!.accountNumber,
      bankName: _selectedMethod!.bankName,
      notes: _notesController.text.trim(),
    );

    try {
      final result = await widget.controller.submitWithdrawalRequest(
        riderId: widget.riderId,
        request: request,
      );
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Cash-out failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AgrisellColors.surface,
      shape: RiderCashOutDialogStyles.dialogShape,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: RiderCashOutDialogStyles.dialogMaxWidth,
        ),
        child: SingleChildScrollView(
          padding: RiderCashOutDialogStyles.dialogPadding,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RiderCashOutHeader(
                  onClose: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: RiderCashOutDialogStyles.sectionGap),
                RiderCashOutBalanceCard(
                  availableEarnings: widget.availableEarnings,
                ),
                const SizedBox(height: RiderCashOutDialogStyles.sectionGap),
                if (_errorMessage != null) ...[
                  RiderCashOutErrorBanner(message: _errorMessage!),
                  const SizedBox(
                    height: RiderCashOutDialogStyles.errorSectionGap,
                  ),
                ],
                RiderCashOutDestinationPicker(
                  methods: widget.controller.withdrawalMethods,
                  selectedMethod: _selectedMethod,
                  onChanged: (val) => setState(() => _selectedMethod = val),
                ),
                const SizedBox(height: RiderCashOutDialogStyles.sectionGap),
                RiderCashOutAmountField(
                  controller: _amountController,
                  availableEarnings: widget.availableEarnings,
                  onQuickAmountSelected: _setAmount,
                ),
                const SizedBox(
                  height: RiderCashOutDialogStyles.notesSectionGap,
                ),
                RiderCashOutNotesField(controller: _notesController),
                const SizedBox(height: RiderCashOutDialogStyles.actionsGap),
                RiderCashOutActions(
                  isSubmitting: _isSubmitting,
                  onCancel: () => Navigator.of(context).pop(),
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
