import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';

/// Owns cash-out inputs, validation, and asynchronous submission feedback.
class FarmerCashOutFormController extends ChangeNotifier {
  FarmerCashOutFormController({double? initialAmount}) {
    amount = TextEditingController(
      text: initialAmount != null && initialAmount > 0
          ? initialAmount.toStringAsFixed(0)
          : '',
    );
  }

  final formKey = GlobalKey<FormState>();
  late final TextEditingController amount;
  final accountName = TextEditingController();
  final accountNumber = TextEditingController();
  final bankName = TextEditingController();
  final notes = TextEditingController();
  String payoutMethod = 'gcash';
  bool isSubmitting = false;
  String? errorMessage;
  bool _disposed = false;

  bool get isBankTransfer => payoutMethod == 'bank_transfer';

  void selectMethod(String method) {
    payoutMethod = method;
    notifyListeners();
  }

  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter an amount';
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Please enter a valid amount greater than 0';
    }
    return null;
  }

  String? validateAccountName(String? value) =>
      value == null || value.trim().isEmpty ? 'Account name is required' : null;

  String? validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return isBankTransfer
          ? 'Account number is required'
          : 'GCash mobile number is required';
    }
    if (!isBankTransfer) {
      final clean = value.replaceAll(RegExp(r'\s+'), '');
      if (!RegExp(r'^09\d{9}$').hasMatch(clean)) {
        return 'Enter a valid 11-digit GCash number (09XXXXXXXXX)';
      }
    }
    return null;
  }

  String? validateBankName(String? value) =>
      isBankTransfer && (value == null || value.trim().isEmpty)
      ? 'Bank name is required for bank transfers'
      : null;

  Future<FarmerCashOutRequest?> submit(
    Future<FarmerCashOutRequest> Function(FarmerCashOutRequest) onSubmit,
  ) async {
    if (isSubmitting || !formKey.currentState!.validate()) return null;
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    final request = FarmerCashOutRequest(
      requestId: '',
      amount: double.tryParse(amount.text.trim()) ?? 0.0,
      payoutMethod: payoutMethod,
      accountName: accountName.text.trim(),
      accountNumber: accountNumber.text.trim(),
      bankName: isBankTransfer ? bankName.text.trim() : '',
      notes: notes.text.trim(),
    );
    try {
      final result = await onSubmit(request);
      return _disposed ? null : result;
    } catch (error) {
      if (_disposed) return null;
      isSubmitting = false;
      errorMessage = 'Failed to submit cash-out request: $error';
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    amount.dispose();
    accountName.dispose();
    accountNumber.dispose();
    bankName.dispose();
    notes.dispose();
    super.dispose();
  }
}
