String? validateWithdrawalAccountName(String? value) =>
    value == null || value.trim().isEmpty ? 'Account name is required' : null;

String? validateWithdrawalAccountNumber(String? value, String payoutMethod) {
  if (value == null || value.trim().isEmpty) {
    return payoutMethod == 'gcash'
        ? 'GCash mobile number is required'
        : 'Account number is required';
  }
  if (payoutMethod == 'gcash') {
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^09\d{9}$').hasMatch(clean)) {
      return 'Enter a valid 11-digit GCash number (09XXXXXXXXX)';
    }
  }
  return null;
}

String? validateWithdrawalBankName(String? value, String payoutMethod) =>
    payoutMethod == 'bank_transfer' && (value == null || value.trim().isEmpty)
    ? 'Bank name is required'
    : null;
