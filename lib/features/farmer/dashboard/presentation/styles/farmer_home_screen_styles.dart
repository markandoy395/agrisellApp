import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerHomeScreenStyles {
  static const background = AgrisellColors.homeBackground;
  static const navBackground = AgrisellColors.surface;
  static const activeBackground = AgrisellColors.authGreen;
  static const activeIconColor = AgrisellColors.surface;
  static const inactiveIconColor = AgrisellColors.brandBlack;
  static const inactiveLabelColor = AgrisellColors.brandBlack;

  static final shadowColor = AgrisellColors.brandBlack.withValues(alpha: 0.16);
}
