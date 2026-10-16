import 'package:flutter/material.dart';
import '../styles/rider_map_progress_styles.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_map_design_styles.dart';

class RiderMapOptionsPoiSection extends StatefulWidget {
  const RiderMapOptionsPoiSection({super.key});

  @override
  State<RiderMapOptionsPoiSection> createState() =>
      _RiderMapOptionsPoiSectionState();
}

class _RiderMapOptionsPoiSectionState extends State<RiderMapOptionsPoiSection> {
  int _selectedPoi = 0;

  static const _pois = [
    (label: 'Markets', icon: Icons.storefront_rounded),
    (label: 'Fuel', icon: Icons.local_gas_station_rounded),
    (label: 'Rest areas', icon: Icons.bed_rounded),
    (label: 'Hospitals', icon: Icons.local_hospital_rounded),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(height: 28),
      const Text(
        'Nearby points of interest',
        style: RiderMapDesignStyles.title,
      ),
      const SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < _pois.length; i++) ...[
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _pois[i].icon,
                        size: 16,
                        color: _selectedPoi == i
                            ? AgrisellColors.surface
                            : AgrisellColors.brandBlack,
                      ),
                      const SizedBox(width: 6),
                      Text(_pois[i].label),
                    ],
                  ),
                  selected: _selectedPoi == i,
                  selectedColor: AgrisellColors.authGreen,
                  onSelected: (val) {
                    if (val) setState(() => _selectedPoi = i);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: RiderMapDesignStyles.carouselIconContainer,
            child: const Icon(
              Icons.local_gas_station_rounded,
              color: AgrisellColors.authGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Nearby fuel stations',
              style: RiderMapDesignStyles.title,
            ),
          ),
          Text(
            'View all >',
            style: RiderMapDesignStyles.caption.copyWith(
              color: AgrisellColors.statusBlueText,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: RiderMapDesignStyles.card,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: RiderMapProgressStyles.poiCircle,
              child: const Icon(
                Icons.local_gas_station_rounded,
                color: AgrisellColors.statusBlueText,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Petron Cabanatuan',
                    style: RiderMapDesignStyles.body,
                  ),
                  Text('0.8 km • 3 min', style: RiderMapDesignStyles.caption),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AgrisellColors.mutedText,
            ),
          ],
        ),
      ),
    ],
  );
}
