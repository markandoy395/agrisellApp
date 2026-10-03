import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/profile/data/farmer_farm_service.dart';
import 'package:agresell_app/features/farmer/registration/domain/farm_model.dart';

class FarmerFarmFormControllers {
  final name = TextEditingController();
  final location = TextEditingController();
  final barangay = TextEditingController();
  final city = TextEditingController();
  final province = TextEditingController();
  final size = TextEditingController();
  final farmingType = TextEditingController();
  final irrigation = TextEditingController();
  final crops = TextEditingController();

  void dispose() {
    name.dispose();
    location.dispose();
    barangay.dispose();
    city.dispose();
    province.dispose();
    size.dispose();
    farmingType.dispose();
    irrigation.dispose();
    crops.dispose();
  }

  void populate(FarmModel? farm) {
    name.text = farm?.name ?? '';
    location.text = farm?.location ?? '';
    barangay.text = farm?.barangay ?? '';
    city.text = farm?.cityMunicipality ?? '';
    province.text = farm?.province ?? '';
    size.text = farm?.size?.toString() ?? '';
    farmingType.text = farm?.farmingType ?? '';
    irrigation.text = farm?.irrigationType ?? '';
    crops.text = farm?.mainCrops.join(', ') ?? '';
  }

  String? validate() {
    final requiredValues = {
      'Farm Name': name.text,
      'Farm Address': location.text,
      'Province': province.text,
      'City or municipality': city.text,
      'Barangay': barangay.text,
      'Farming Type': farmingType.text,
      'Main Crops': crops.text,
    };
    for (final entry in requiredValues.entries) {
      if (entry.value.trim().isEmpty) {
        return 'Enter ${entry.key}.';
      }
    }
    final parsedSize = double.tryParse(size.text.trim());
    if (parsedSize == null || !parsedSize.isFinite || parsedSize <= 0) {
      return 'Enter a valid farm size in hectares.';
    }
    return null;
  }

  FarmEditDraft buildDraft({double? latitude, double? longitude}) {
    return FarmEditDraft(
      name: name.text,
      location: _blank(location.text),
      barangay: _blank(barangay.text),
      cityMunicipality: _blank(city.text),
      province: _blank(province.text),
      latitude: latitude,
      longitude: longitude,
      size: double.tryParse(size.text.trim()),
      farmingType: _blank(farmingType.text),
      irrigationType: _blank(irrigation.text),
      mainCrops: crops.text
          .split(',')
          .map((crop) => crop.trim())
          .where((crop) => crop.isNotEmpty)
          .toList(growable: false),
    );
  }

  static String? _blank(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
