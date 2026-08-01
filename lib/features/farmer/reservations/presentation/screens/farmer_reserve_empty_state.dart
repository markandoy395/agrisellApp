part of 'farmer_reserve_screen.dart';

class _ReservationLoadingState extends StatelessWidget {
  const _ReservationLoadingState();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 12),
        Text(
          'Loading reservations',
          style: TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
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
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AgrisellColors.authGreen,
            size: 38,
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to load reservations',
            style: TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Check your connection and try again.',
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

class _EmptyReservations extends StatelessWidget {
  const _EmptyReservations();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(24, 34, 24, 24),
    child: Column(
      children: [
        Icon(
          Icons.receipt_long_outlined,
          color: AgrisellColors.authGreen,
          size: 34,
        ),
        SizedBox(height: 10),
        Text(
          'No reservations',
          style: TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Buyer reservations returned by the backend will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
        ),
      ],
    ),
  );
}
