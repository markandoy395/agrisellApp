part of 'farmer_screen.dart';

class _FarmerLoading extends StatelessWidget {
  const _FarmerLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(28),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _FarmerLoadFailure extends StatelessWidget {
  const _FarmerLoadFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AgrisellColors.surface,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AgrisellColors.authGreen,
            size: 38,
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to load farmers',
            style: TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Check your connection and make sure the farmer directory migration has been applied.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

class _EmptyFarmerResults extends StatelessWidget {
  const _EmptyFarmerResults({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AgrisellColors.surface,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Icon(
            Icons.manage_search_rounded,
            color: AgrisellColors.authGreen,
            size: 38,
          ),
          const SizedBox(height: 10),
          const Text(
            'No farmers found',
            style: TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Try a farmer name, location, or produce type.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onClear, child: const Text('Clear search')),
        ],
      ),
    ),
  );
}
