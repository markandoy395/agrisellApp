part of 'farmer_reserve_screen.dart';

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
