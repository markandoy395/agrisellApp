import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

Future<String?> showFarmCreationDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _FarmCreationDialog(),
  );
}

class _FarmCreationDialog extends StatefulWidget {
  const _FarmCreationDialog();

  @override
  State<_FarmCreationDialog> createState() => _FarmCreationDialogState();
}

class _FarmCreationDialogState extends State<_FarmCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set up your farm'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Farm name',
            hintText: 'Enter your farm name',
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter your farm name.'
              : null,
          onFieldSubmitted: (_) => _createFarm(),
        ),
      ),
      actions: [
        TextButton(onPressed: _cancel, child: const Text('Cancel')),
        FilledButton(
          onPressed: _createFarm,
          style: FilledButton.styleFrom(
            backgroundColor: AgrisellColors.authGreen,
            foregroundColor: AgrisellColors.surface,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _cancel() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop();
  }

  void _createFarm() {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(_controller.text.trim());
  }
}
