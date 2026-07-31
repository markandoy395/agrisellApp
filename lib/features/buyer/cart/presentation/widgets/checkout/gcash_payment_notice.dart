part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _GcashVerificationNotice extends StatelessWidget {
  const _GcashVerificationNotice({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: AgrisellColors.statusBlueBackground,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.shield_outlined,
          size: 19,
          color: AgrisellColors.statusBlueText,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'Amount to transfer: ${formatBasketPeso(total)}\n',
              style: const TextStyle(
                color: AgrisellColors.statusBlueText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
              children: const [
                TextSpan(
                  text:
                      'Your reference is submitted for verification and does not mark the order paid.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _GcashAccountCard extends StatelessWidget {
  const _GcashAccountCard({required this.details});

  final FarmerGcashDetails details;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AgrisellColors.forestSoft,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AgrisellColors.authGreen),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.farmerName,
          style: const TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        _GcashDetailLine(label: 'Account name', value: details.accountName),
        const SizedBox(height: 5),
        _GcashDetailLine(label: 'GCash number', value: details.accountNumber),
      ],
    ),
  );
}

class _GcashDetailLine extends StatelessWidget {
  const _GcashDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 95,
        child: Text(
          label,
          style: const TextStyle(color: AgrisellColors.mutedText, fontSize: 12),
        ),
      ),
      Expanded(
        child: SelectableText(
          value,
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  );
}

class _GcashLoadingState extends StatelessWidget {
  const _GcashLoadingState();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 104,
    child: Center(
      child: CircularProgressIndicator(
        color: AgrisellColors.authGreen,
        strokeWidth: 2.5,
      ),
    ),
  );
}

class _GcashUnavailableState extends StatelessWidget {
  const _GcashUnavailableState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AgrisellColors.statusOrangeBackground,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: AgrisellColors.statusOrangeText,
          size: 20,
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Text(
            'This farmer has not shared complete GCash details. Choose Cash on Delivery for now.',
            style: TextStyle(
              color: AgrisellColors.statusOrangeText,
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
