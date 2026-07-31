import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_action_button.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_form_rows.dart';
import 'package:agresell_app/features/farmer/profile/data/farmer_farm_service.dart';
import 'package:agresell_app/features/farmer/registration/domain/farm_model.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_psgc_address_fields.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/presentation/location_selector.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_section_label.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class FarmerFarmEditCard extends StatefulWidget {
  const FarmerFarmEditCard({required this.onCancel, super.key});
  final VoidCallback onCancel;
  @override
  State<FarmerFarmEditCard> createState() => _FarmerFarmEditCardState();
}

class _FarmerFarmEditCardState extends State<FarmerFarmEditCard> {
  final _service = const FarmerFarmService();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _barangayController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _sizeController = TextEditingController();
  final _farmingTypeController = TextEditingController();
  final _irrigationController = TextEditingController();
  final _cropsController = TextEditingController();
  FarmModel? _farm;
  var _loading = true;
  var _saving = false;
  double? _latitude;
  double? _longitude;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _barangayController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _sizeController.dispose();
    _farmingTypeController.dispose();
    _irrigationController.dispose();
    _cropsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final farm = await _service.load();
      if (!mounted) return;
      _farm = farm;
      _nameController.text = farm?.name ?? '';
      _locationController.text = farm?.location ?? '';
      _barangayController.text = farm?.barangay ?? '';
      _cityController.text = farm?.cityMunicipality ?? '';
      _provinceController.text = farm?.province ?? '';
      _latitude = farm?.latitude;
      _longitude = farm?.longitude;
      _sizeController.text = farm?.size?.toString() ?? '';
      _farmingTypeController.text = farm?.farmingType ?? '';
      _irrigationController.text = farm?.irrigationType ?? '';
      _cropsController.text = farm?.mainCrops.join(', ') ?? '';
    } on FarmerFarmException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final farm = await _service.save(
        FarmEditDraft(
          name: _nameController.text,
          location: _blank(_locationController.text),
          barangay: _blank(_barangayController.text),
          cityMunicipality: _blank(_cityController.text),
          province: _blank(_provinceController.text),
          latitude: _latitude,
          longitude: _longitude,
          size: double.tryParse(_sizeController.text.trim()),
          farmingType: _blank(_farmingTypeController.text),
          irrigationType: _blank(_irrigationController.text),
          mainCrops: _cropsController.text
              .split(',')
              .map((crop) => crop.trim())
              .where((crop) => crop.isNotEmpty)
              .toList(growable: false),
        ),
        farmId: _farm?.id,
      );
      if (!mounted) return;
      setState(() => _farm = farm);
      _message('Farm details saved.');
    } on FarmerFarmException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickLocation() async {
    final location = await showLocationSelector(
      context,
      role: LocationOwnerRole.farmer,
      initialAddress: _locationController.text,
    );
    if (location == null || !mounted) return;
    setState(() {
      _latitude = location.latitude;
      _longitude = location.longitude;
      if (_locationController.text.trim().isEmpty) {
        _locationController.text = location.address ?? location.notes ?? '';
      }
    });
  }

  String? _blank(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  void _message(String value) {
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCardShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfileSectionLabel(text: 'My Farm'),
                  const SizedBox(height: 6),
                  Text(
                    'Update the farm used for your product listings.',
                    style: ProfileTextStyles.profileDescription(context),
                  ),
                  const SizedBox(height: 10),
                  ProfileEditFieldRow(
                    label: 'Farm Name',
                    controller: _nameController,
                  ),
                  ProfileEditFieldRow(
                    label: 'Farm Address',
                    controller: _locationController,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _pickLocation,
                      icon: const Icon(Icons.location_on_outlined, size: 18),
                      label: Text(
                        _latitude == null || _longitude == null
                            ? 'Choose exact GPS location'
                            : 'Farm location pinned',
                      ),
                    ),
                  ),
                  FarmerPsgcAddressFields(
                    provinceController: _provinceController,
                    cityController: _cityController,
                    barangayController: _barangayController,
                    onChanged: () => setState(() {}),
                  ),
                  ProfileEditFieldRow(
                    label: 'Size (hectares)',
                    controller: _sizeController,
                    keyboardType: TextInputType.number,
                  ),
                  ProfileEditFieldRow(
                    label: 'Farming Type',
                    controller: _farmingTypeController,
                  ),
                  ProfileEditFieldRow(
                    label: 'Irrigation Type',
                    controller: _irrigationController,
                  ),
                  ProfileEditFieldRow(
                    label: 'Main Crops',
                    controller: _cropsController,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ProfileEditActionButton(
                        label: 'Cancel',
                        onPressed: widget.onCancel,
                        isPrimary: false,
                      ),
                      const SizedBox(width: 14),
                      ProfileEditActionButton(
                        label: _saving ? 'Saving...' : 'Save Farm',
                        onPressed: _saving ? () {} : _save,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
