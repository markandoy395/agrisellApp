import 'package:flutter_map/flutter_map.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Predefined style constants and metrics for the rider live map layer.
abstract final class RiderLiveMapStyles {
  // Tile Server & Map Defaults
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String satelliteTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const String terrainTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';
  static const String osmUserAgent = 'com.agrisell.agresell_app';
  static const String osmAttribution = 'OpenStreetMap contributors';

  static const double initialZoom = 15.0;
  static const double minZoom = 4.0;
  static const double maxZoom = 19.0;

  // Polyline Styling
  static const double roadAccessStrokeWidth = 2.2;
  static final roadAccessColor = AgrisellColors.mutedText.withValues(
    alpha: 0.78,
  );
  static final roadAccessPattern = StrokePattern.dashed(segments: const [5, 5]);

  static const double activeRouteStrokeWidth = 6.5;
  static const activeRouteColor = AgrisellColors.statusBlueText;

  static const double inactiveRouteStrokeWidth = 3.0;
  static final inactiveRouteColor = AgrisellColors.mutedText.withValues(
    alpha: 0.32,
  );

  // Marker Sizes & Dimensions
  static const double prominentMarkerExtent = 64.0;
  static const double standardMarkerExtent = 56.0;
  static const double clusterMarkerExtent = 48.0;

  static const double prominentIconSize = 28.0;
  static const double standardIconSize = 24.0;
  static const double clusterIconSize = 28.0;

  static const markerIconColor = AgrisellColors.brandBlack;

  // Puck and Halo Dimensions
  static const double puckSize = 42.0;
  static const double radarRadius = 76.0;
  static const puckColor = AgrisellColors.statusBlueText;
  static const radarColor = AgrisellColors.routeRadar;
}
