part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _GcashVerificationNotice extends StatelessWidget {
  const _GcashVerificationNotice({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: GcashPaymentNoticeStyles.containerDecoration,
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
              style: GcashPaymentNoticeStyles.textStyle,
              children: const [
                TextSpan(
                  text:
                      'Your reference is submitted for verification and does not mark the order paid.',
                  style: SharedPresentationStyles.captionMedium,
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
    decoration: GcashPaymentNoticeStyles.containerDecoration2,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.farmerName,
          style: SharedPresentationStyles.headingBodyExtraBold,
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
        child: Text(label, style: SharedPresentationStyles.mutedCaption),
      ),
      Expanded(
        child: SelectableText(
          value,
          style: SharedPresentationStyles.inkBodyExtraBold,
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
    decoration: GcashPaymentNoticeStyles.containerDecoration3,
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
            style: GcashPaymentNoticeStyles.textStyle3,
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
