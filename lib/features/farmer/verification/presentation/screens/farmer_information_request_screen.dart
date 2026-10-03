import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';

import '../controllers/farmer_information_request_form_controller.dart';
import '../widgets/farmer_information_request_content.dart';

class FarmerInformationRequestScreen extends StatefulWidget {
  const FarmerInformationRequestScreen({
    required this.details,
    this.repository = const FarmerVerificationRepository(),
    super.key,
  });

  final FarmerVerificationDetails details;
  final FarmerVerificationRepository repository;

  @override
  State<FarmerInformationRequestScreen> createState() =>
      _FarmerInformationRequestScreenState();
}

class _FarmerInformationRequestScreenState
    extends State<FarmerInformationRequestScreen> {
  late final FarmerInformationRequestFormController _form;

  Uint8List? _profileImageBytes;
  Uint8List? _farmImageBytes;
  var _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _form = FarmerInformationRequestFormController(widget.details);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isProfile}) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        if (isProfile) {
          _profileImageBytes = bytes;
        } else {
          _farmImageBytes = bytes;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('Unable to select photo.')),
      );
    }
  }

  Future<void> _submitCorrections() async {
    final firstName = _form.firstName.text.trim();
    final lastName = _form.lastName.text.trim();
    final phone = _form.phone.text.trim();
    final farmName = _form.farmName.text.trim();
    final farmAddress = _form.farmAddress.text.trim();
    final notes = _form.notes.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('First and last name are required.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.repository.resubmitVerification(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phone.isNotEmpty ? phone : null,
        farmName: farmName.isNotEmpty ? farmName : null,
        farmAddress: farmAddress.isNotEmpty ? farmAddress : null,
        profileImageBytes: _profileImageBytes,
        farmImageBytes: _farmImageBytes,
        notes: notes.isNotEmpty ? notes : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(
          content: Text(
            'Corrections submitted successfully! Admin will re-evaluate your profile.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(
          content: Text('Failed to submit corrections. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FarmerInformationRequestContent(
      details: widget.details,
      form: _form,
      profileImageBytes: _profileImageBytes,
      farmImageBytes: _farmImageBytes,
      isSubmitting: _isSubmitting,
      onPickProfile: () => _pickImage(isProfile: true),
      onPickFarm: () => _pickImage(isProfile: false),
      onSubmit: _submitCorrections,
    );
  }
}
