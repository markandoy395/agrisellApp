import 'package:agresell_app/features/shared/location/presentation/styles/location_map_preview_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/map_coordinates.dart';

class LocationMapPreview extends StatelessWidget {
  const LocationMapPreview({
    required this.latitude,
    required this.longitude,
    required this.onTap,
    required this.emptyLabel,
    required this.selectedLabel,
    super.key,
  });

  final double? latitude;
  final double? longitude;
  final VoidCallback onTap;
  final String emptyLabel;
  final String selectedLabel;

  @override
  Widget build(BuildContext context) {
    final hasLocation = MapCoordinates.isValid(
      latitude: latitude,
      longitude: longitude,
    );
    final point = hasLocation
        ? LatLng(latitude!, longitude!)
        : const LatLng(12.8797, 121.7740);
    return Semantics(
      button: true,
      label: hasLocation ? selectedLabel : emptyLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 142,
          decoration: LocationMapPreviewStyles.inkDecoration,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              children: [
                IgnorePointer(
                  child: FlutterMap(
                    key: ValueKey(
                      '${point.latitude.toStringAsFixed(6)},'
                      '${point.longitude.toStringAsFixed(6)}',
                    ),
                    options: MapOptions(
                      initialCenter: point,
                      initialZoom: hasLocation ? 15 : 5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.agrisell.agresell_app',
                      ),
                      if (hasLocation)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: point,
                              width: 40,
                              height: 44,
                              child: const Icon(
                                Icons.location_pin,
                                color: AgrisellColors.statusRedText,
                                size: 38,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: DecoratedBox(
                    decoration: LocationMapPreviewStyles.decoratedBoxDecoration,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.map_outlined,
                            size: 17,
                            color: AgrisellColors.authGreen,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              hasLocation ? selectedLabel : emptyLabel,
                              style: SharedPresentationStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
