import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';

class FarmerAvatar extends StatelessWidget {
  const FarmerAvatar({required this.farmer, required this.size, super.key});

  final FarmerProfile farmer;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageUrl = farmer.imageUrl;

    return Semantics(
      image: true,
      label: '${farmer.name} profile avatar',
      child: ClipOval(
        child: imageUrl == null
            ? ColoredBox(
                color: AgrisellColors.forestSoft,
                child: SizedBox.square(
                  dimension: size,
                  child: Center(
                    child: Text(
                      farmer.initials,
                      style: TextStyle(
                        color: AgrisellColors.forestDark,
                        fontSize: size < 50 ? 14 : 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            : ResponsiveAssetImage(
                imageUrl: imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
      ),
    );
  }
}
