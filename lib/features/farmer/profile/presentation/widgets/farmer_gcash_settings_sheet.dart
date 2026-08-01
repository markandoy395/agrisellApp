import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/profile/data/farmer_payment_settings_repository.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_gcash_settings_widgets.dart';

Future<void> showFarmerGcashSettingsSheet(
  BuildContext context, {
  FarmerPaymentSettingsRepository repository =
      const FarmerPaymentSettingsRepository(),
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: AgrisellColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _FarmerGcashSettingsSheet(repository: repository),
  );
}

class _FarmerGcashSettingsSheet extends StatefulWidget {
  const _FarmerGcashSettingsSheet({required this.repository});

  final FarmerPaymentSettingsRepository repository;

  @override
  State<_FarmerGcashSettingsSheet> createState() =>
      _FarmerGcashSettingsSheetState();
}

class _FarmerGcashSettingsSheetState extends State<_FarmerGcashSettingsSheet> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  var _loading = true;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final details = await widget.repository.load();
      if (!mounted) return;
      _nameController.text = details?.accountName ?? '';
      _numberController.text = details?.accountNumber ?? '';
      setState(() => _loading = false);
    } on Object {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'GCash details could not be loaded.';
      });
    }
  }

  bool get _isValid {
    final name = _nameController.text.trim();
    final number = _numberController.text.replaceAll(RegExp(r'[ -]'), '');
    return name.length >= 2 &&
        name.length <= 80 &&
        RegExp(r'^(09\d{9}|(?:\+?63)9\d{9})$').hasMatch(number);
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(18, 12, 18, 18 + inset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FarmerGcashSettingsHeader(
            onClose: _saving ? null : () => Navigator.of(context).pop(),
          ),
          const Text(
            'Buyers see these details only when they choose GCash for your products.',
            style: TextStyle(
              color: AgrisellColors.mutedText,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 13),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                color: AgrisellColors.authGreen,
                strokeWidth: 2.5,
              ),
            )
          else ...[
            FarmerGcashSettingsField(
              controller: _nameController,
              label: 'GCash account name',
              icon: Icons.person_outline_rounded,
              enabled: !_saving,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 10),
            FarmerGcashSettingsField(
              controller: _numberController,
              label: 'GCash mobile number',
              icon: Icons.phone_android_outlined,
              enabled: !_saving,
              isPhone: true,
              onChanged: () => setState(() {}),
            ),
            if (_error case final message?) ...[
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  color: AgrisellColors.statusRedText,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 13),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: FilledButton.icon(
                onPressed: _saving || !_isValid ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AgrisellColors.authGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.lock_outline_rounded, size: 16),
                label: Text(
                  _saving ? 'Saving…' : 'Save GCash details',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.save(
        accountName: _nameController.text,
        accountNumber: _numberController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showAppSnackBar(
        const SnackBar(content: Text('GCash payment details saved.')),
      );
    } on FarmerPaymentSettingsException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.message;
      });
    }
  }
}
