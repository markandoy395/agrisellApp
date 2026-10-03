part of 'farmer_reserve_screen.dart';

class _ReservationLoadingState extends StatelessWidget {
  const _ReservationLoadingState();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        FarmerReserveStyles.spacingLarge,
        Text(
          'Loading reservations',
          style: FarmerReserveStyles.loadingTitleStyle,
        ),
      ],
    ),
  );
}

class _ReservationLoadFailure extends StatelessWidget {
  const _ReservationLoadFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: FarmerReserveStyles.errorPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: FarmerReserveStyles.emptyIconColor,
            size: 38,
          ),
          FarmerReserveStyles.spacingMedium,
          const Text(
            'Unable to load reservations',
            style: FarmerReserveStyles.errorTitleStyle,
          ),
          FarmerReserveStyles.spacingSmall,
          const Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: FarmerReserveStyles.errorSubtitleStyle,
          ),
          FarmerReserveStyles.spacingLarge,
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

class _EmptyReservations extends StatelessWidget {
  const _EmptyReservations({this.hasSearch = false});

  final bool hasSearch;

  @override
  Widget build(BuildContext context) => Padding(
    padding: FarmerReserveStyles.emptyPadding,
    child: Column(
      children: [
        const Icon(
          Icons.receipt_long_outlined,
          color: FarmerReserveStyles.emptyIconColor,
          size: 34,
        ),
        FarmerReserveStyles.spacingMedium,
        Text(
          hasSearch ? 'No matching reservations' : 'No reservations',
          style: FarmerReserveStyles.emptyTitleStyle,
        ),
        FarmerReserveStyles.spacingSmall,
        Text(
          hasSearch
              ? 'Try a different order number, product, or delivery address.'
              : 'Buyer reservations returned by the backend will appear here.',
          textAlign: TextAlign.center,
          style: FarmerReserveStyles.emptySubtitleStyle,
        ),
      ],
    ),
  );
}
