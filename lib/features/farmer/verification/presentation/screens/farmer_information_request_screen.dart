import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';

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
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _farmNameController;
  late final TextEditingController _farmAddressController;
  late final TextEditingController _notesController;

  Uint8List? _profileImageBytes;
  Uint8List? _farmImageBytes;
  var _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final d = widget.details;
    _firstNameController = TextEditingController(text: d.firstName ?? '');
    _lastNameController = TextEditingController(text: d.lastName ?? '');
    _phoneController = TextEditingController(text: d.phoneNumber ?? '');
    _farmNameController = TextEditingController(text: d.farmName ?? '');
    _farmAddressController = TextEditingController(text: d.farmAddress ?? '');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _farmNameController.dispose();
    _farmAddressController.dispose();
    _notesController.dispose();
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
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final farmName = _farmNameController.text.trim();
    final farmAddress = _farmAddressController.text.trim();
    final notes = _notesController.text.trim();

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
    final d = widget.details;

    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(
        backgroundColor: AgrisellColors.authGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Information Requested',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeedbackCard(d),
              const SizedBox(height: 20),
              _buildFormSection(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitCorrections,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgrisellColors.authGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Submit Corrections',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(FarmerVerificationDetails d) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE65100).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE65100),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ACTION REQUIRED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Text(
                  'Requested: ${d.formattedRequestedDate}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AgrisellColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'NOTE FROM REVIEWER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFFBF360C),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Text(
                d.hasMessage
                    ? d.message!
                    : 'Please review your farmer profile and submit the missing or outdated verification information.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AgrisellColors.brandBlack,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (d.hasMissingItems) ...[
              const SizedBox(height: 14),
              const Text(
                'MISSING OR REQUESTED ITEMS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFBF360C),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              ...d.missingItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_box_outline_blank_rounded,
                        color: Color(0xFFE65100),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AgrisellColors.brandBlack,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AgrisellColors.borderLine),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update Profile & Documents',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AgrisellColors.brandBlack,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Correct any flagged information or re-upload clear photos/documents below.',
            style: TextStyle(
              fontSize: 12,
              color: AgrisellColors.mutedText,
            ),
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _firstNameController,
            label: 'First Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _lastNameController,
            label: 'Last Name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _farmNameController,
            label: 'Farm Name',
            icon: Icons.agriculture_rounded,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _farmAddressController,
            label: 'Farm Address / Location',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          const Text(
            'Verification Photos & Documents',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AgrisellColors.brandBlack,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildUploadCard(
                  title: 'Profile Photo',
                  hasImage: _profileImageBytes != null ||
                      (widget.details.profileImageUrl?.isNotEmpty == true),
                  imageBytes: _profileImageBytes,
                  onPick: () => _pickImage(isProfile: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUploadCard(
                  title: 'Farm / Certificate',
                  hasImage: _farmImageBytes != null ||
                      widget.details.farmImages.isNotEmpty,
                  imageBytes: _farmImageBytes,
                  onPick: () => _pickImage(isProfile: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          const Text(
            'Note to Reviewer',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AgrisellColors.brandBlack,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Explain the corrections you made...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AgrisellColors.mutedText,
              ),
              filled: true,
              fillColor: AgrisellColors.homeBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AgrisellColors.borderLine),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AgrisellColors.borderLine),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AgrisellColors.authGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AgrisellColors.brandBlack,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AgrisellColors.mutedText),
            filled: true,
            fillColor: AgrisellColors.homeBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AgrisellColors.borderLine),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AgrisellColors.borderLine),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AgrisellColors.authGreen,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required bool hasImage,
    required Uint8List? imageBytes,
    required VoidCallback onPick,
  }) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AgrisellColors.homeBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage ? AgrisellColors.authGreen : AgrisellColors.borderLine,
            width: hasImage ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            if (imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imageBytes,
                  height: 60,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Icon(
                hasImage ? Icons.check_circle_outline_rounded : Icons.cloud_upload_outlined,
                size: 32,
                color: hasImage ? AgrisellColors.authGreen : AgrisellColors.mutedText,
              ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AgrisellColors.brandBlack,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasImage ? 'Tap to change' : 'Tap to upload',
              style: const TextStyle(
                fontSize: 12,
                color: AgrisellColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
