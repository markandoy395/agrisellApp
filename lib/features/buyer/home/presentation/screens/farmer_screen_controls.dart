part of 'farmer_screen.dart';

class _FarmerListControls extends StatelessWidget {
  const _FarmerListControls({
    required this.resultCount,
    required this.availableOnly,
    required this.followingOnly,
    required this.selectedLocation,
    required this.locations,
    required this.sortLabel,
    required this.onAvailableChanged,
    required this.onFollowingChanged,
    required this.onLocationChanged,
    required this.onSort,
  });

  final int resultCount;
  final bool availableOnly;
  final bool followingOnly;
  final String? selectedLocation;
  final List<String> locations;
  final String sortLabel;
  final ValueChanged<bool> onAvailableChanged;
  final ValueChanged<bool> onFollowingChanged;
  final ValueChanged<String?> onLocationChanged;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '$resultCount ${resultCount == 1 ? 'farmer' : 'farmers'} found',
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onSort,
            icon: const Icon(Icons.swap_vert_rounded, size: 18),
            label: Text(sortLabel),
            style: TextButton.styleFrom(
              foregroundColor: AgrisellColors.authGreen,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            FilterChip(
              label: const Text('All farmers'),
              selected:
                  !availableOnly && !followingOnly && selectedLocation == null,
              onSelected: (_) {
                onAvailableChanged(false);
                onFollowingChanged(false);
                onLocationChanged(null);
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              avatar: const Icon(Icons.people_alt_outlined, size: 16),
              label: const Text('Following'),
              selected: followingOnly,
              onSelected: onFollowingChanged,
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Available now'),
              selected: availableOnly,
              onSelected: onAvailableChanged,
            ),
            for (final location in locations) ...[
              const SizedBox(width: 8),
              FilterChip(
                label: Text(location),
                selected: selectedLocation == location,
                onSelected: (selected) =>
                    onLocationChanged(selected ? location : null),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}
