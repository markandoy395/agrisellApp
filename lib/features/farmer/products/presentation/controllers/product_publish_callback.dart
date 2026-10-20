import 'package:flutter/material.dart';
import '../../domain/farmer_dashboard_product.dart';

typedef ProductPublishCallback =
    Future<FarmerDashboardProduct?> Function(
      BuildContext context,
      FarmerDashboardProduct product,
      String requestKey,
    );
