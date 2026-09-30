abstract final class FarmerRegistrationChoices {
  static const farmSizeUnits = ['ha', 'sq m'];

  static const farmingTypes = [
    'Rice (Palay)',
    'Corn',
    'High-Value Crops (Vegetables, Fruits, Coconut, Sugarcane)',
    'Livestock (Swine, Poultry, Cattle, Goats)',
    'Fisheries / Aquaculture',
    'Agroforestry',
  ];

  static const landTenures = [
    'Registered Owner',
    'Agrarian Reform Beneficiary (CLOA/EP Holder)',
    'Tenant / Lessee',
    'Ancestral Domain (CADT Holder)',
  ];

  /// NIA system categories, PSA rainfed classification, and DA irrigation
  /// methods: https://www.nia.gov.ph/node/59
  /// https://rssocar.psa.gov.ph/crops/node/55014?page=1
  /// https://bafs.da.gov.ph/index.php/approved-philippine-national-standards/
  static const irrigationTypes = [
    'Rainfed / No Irrigation',
    'National Irrigation System (NIS)',
    'Communal Irrigation System (CIS)',
    'Private / Individual Irrigation',
    'Pump Irrigation',
    'Surface Irrigation (Basin / Border / Furrow)',
    'Sprinkler Irrigation',
    'Drip Irrigation',
  ];
}
