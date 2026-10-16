import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/rider_map_visibility.dart';
import '../styles/rider_map_design_styles.dart';
import '../styles/rider_map_options_styles.dart';
import 'rider_map_options_poi_section.dart';
import 'rider_map_overlays.dart';
import 'rider_map_types.dart';
import 'rider_map_view_selector.dart';

Future<void> showRiderMapOptions(
  BuildContext context, {
  required RiderMapVisibility visibility,
  required ValueChanged<RiderMapVisibility> onChanged,
  required RiderMapFilter filter,
  required ValueChanged<RiderMapFilter> onFilterChanged,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (context) => _MapOptions(
    visibility: visibility,
    onChanged: onChanged,
    filter: filter,
    onFilterChanged: onFilterChanged,
  ),
);

class _MapOptions extends StatefulWidget {
  const _MapOptions({
    required this.visibility,
    required this.onChanged,
    required this.filter,
    required this.onFilterChanged,
  });
  final RiderMapVisibility visibility;
  final ValueChanged<RiderMapVisibility> onChanged;
  final RiderMapFilter filter;
  final ValueChanged<RiderMapFilter> onFilterChanged;

  @override
  State<_MapOptions> createState() => _MapOptionsState();
}

class _MapOptionsState extends State<_MapOptions> {
  late RiderMapVisibility _layers = widget.visibility;
  late RiderMapFilter _filter = widget.filter;

  void _change(RiderMapVisibility layers) {
    setState(() => _layers = layers);
    widget.onChanged(layers);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              const Expanded(
                child: Text('Map options', style: RiderMapDesignStyles.title),
              ),
              IconButton(
                tooltip: 'Close map options',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RiderMapViewSelector(
                  selectedType: _layers.mapViewType,
                  onSelect: (type) =>
                      _change(_layers.copyWith(mapViewType: type)),
                ),
                const Divider(height: 28),
                const Text('Show on map', style: RiderMapDesignStyles.title),
                _toggle(
                  'Pickup requests',
                  RiderMapFilter.deliveries.icon,
                  AgrisellColors.authGreen,
                  _layers.pickups,
                  (v) => _change(_layers.copyWith(pickups: v)),
                ),
                _toggle(
                  'Active deliveries',
                  RiderMapFilter.assigned.icon,
                  AgrisellColors.authGreen,
                  _layers.active,
                  (v) => _change(_layers.copyWith(active: v)),
                ),
                _toggle(
                  'Drop-off locations',
                  Icons.location_on_outlined,
                  AgrisellColors.statusRedText,
                  _layers.dropOffs,
                  (v) => _change(_layers.copyWith(dropOffs: v)),
                ),
                _toggle(
                  'Points of interest',
                  Icons.place_outlined,
                  AgrisellColors.statusBlueText,
                  _layers.pointsOfInterest,
                  (v) => _change(_layers.copyWith(pointsOfInterest: v)),
                ),
                _toggle(
                  'Traffic conditions',
                  Icons.traffic_outlined,
                  AgrisellColors.authGreen,
                  false,
                  null,
                ),
                const RiderMapOptionsPoiSection(),
                const Divider(height: 24),
                const Text('Focus map', style: RiderMapDesignStyles.title),
                const SizedBox(height: 8),
                RiderMapFilters(
                  selected: _filter,
                  onChanged: (value) {
                    setState(() => _filter = value);
                    widget.onFilterChanged(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _toggle(
    String label,
    IconData icon,
    Color iconColor,
    bool value,
    ValueChanged<bool>? onChanged,
  ) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    secondary: Container(
      padding: const EdgeInsets.all(6),
      decoration: RiderMapOptionsStyles.iconBadge(iconColor),
      child: Icon(icon, color: iconColor, size: 20),
    ),
    title: Text(label, style: RiderMapDesignStyles.body),
    subtitle: onChanged == null
        ? Text('Unavailable', style: RiderMapDesignStyles.caption)
        : null,
    value: value,
    onChanged: onChanged,
  );
}
