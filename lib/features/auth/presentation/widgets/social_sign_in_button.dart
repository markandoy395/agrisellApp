import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/responsive.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';

enum SocialBrand { facebook, google }

class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    required this.brand,
    required this.label,
    super.key,
  });

  final SocialBrand brand;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 238),
        child: SizedBox(
          width: double.infinity,
          height: 38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SocialIcon(brand: brand),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AgrisellColors.brandBlack,
                    fontSize: lerpDouble(12, 14, scale),
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.brand});

  static const double _defaultSize = 30;
  static const double _facebookSize = 34;

  final SocialBrand brand;

  double get _size => switch (brand) {
    SocialBrand.facebook => _facebookSize,
    SocialBrand.google => _defaultSize,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: switch (brand) {
        SocialBrand.facebook => 'Facebook',
        SocialBrand.google => 'Google',
      },
      child: ExcludeSemantics(
        child: ClipRect(
          child: SizedBox.square(
            dimension: _size,
            child: ResponsiveAssetImage(
              asset: switch (brand) {
                SocialBrand.facebook => AgrisellAssets.facebookLogo,
                SocialBrand.google => AgrisellAssets.googleLogo,
              },
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              excludeFromSemantics: true,
              // Decode by height so wide assets keep their aspect ratio
              // before BoxFit crops them into the square icon frame.
              maxDecodedWidth: 0,
            ),
          ),
        ),
      ),
    );
  }
}
