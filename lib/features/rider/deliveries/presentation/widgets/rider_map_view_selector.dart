import 'package:flutter/material.dart';
import '../../domain/rider_map_visibility.dart';
import '../styles/rider_map_view_styles.dart';
import 'rider_map_view_preview.dart';

class RiderMapViewSelector extends StatelessWidget {
  const RiderMapViewSelector({
    required this.selectedType,
    required this.onSelect,
    super.key,
  });
  final RiderMapViewType selectedType;
  final ValueChanged<RiderMapViewType> onSelect;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Map view', style: RiderMapViewStyles.title),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final type in RiderMapViewType.values) ...[
            if (type != RiderMapViewType.values.first) const SizedBox(width: 8),
            Expanded(child: _option(type)),
          ],
        ],
      ),
    ],
  );

  Widget _option(RiderMapViewType type) {
    final selected = selectedType == type;
    final label = switch (type) {
      RiderMapViewType.defaultView => 'Default',
      RiderMapViewType.satellite => 'Satellite',
      RiderMapViewType.terrain => 'Terrain',
    };
    return Semantics(
      selected: selected,
      button: true,
      child: DecoratedBox(
        decoration: RiderMapViewStyles.card(selected),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('map-view-${type.name}'),
            borderRadius: RiderMapViewStyles.cardRadius,
            onTap: () => onSelect(type),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  RiderMapViewPreview(type: type),
                  const SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: RiderMapViewStyles.label,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
