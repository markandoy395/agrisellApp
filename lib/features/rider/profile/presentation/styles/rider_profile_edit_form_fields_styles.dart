import 'package:flutter/material.dart';
import 'rider_profile_design_styles.dart';

abstract final class RiderProfileEditFormFieldsStyles {
  static InputDecoration inputDecoration(String label) =>
      RiderProfileDesignStyles.input(label);
}
