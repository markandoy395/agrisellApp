import 'package:flutter/material.dart';

abstract final class RiderVehicleScreenStyles {
  static InputDecoration inputDecoration(List<String> fieldLabels, int index) =>
      InputDecoration(labelText: fieldLabels[index]);
}
