part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.onMessagesTap});

  final VoidCallback onMessagesTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final horizontalPadding = width < 380 ? 12.0 : 16.0;
    final topPadding = (topInset > 0 ? topInset : 24.0) + 10;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        14,
      ),
      decoration: CheckoutHeaderStyles.containerDecoration,
      child: Row(
        children: [
          _HeaderCircleButton(
            semanticLabel: 'Go back',
            child: const Icon(
              Icons.arrow_back,
              color: AgrisellColors.surface,
              size: 24,
            ),
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Checkout',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CheckoutHeaderStyles.checkoutText,
            ),
          ),
          _HeaderChatButton(onTap: onMessagesTap),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.semanticLabel,
    required this.child,
    required this.onTap,
  });

  final String semanticLabel;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 38,
        child: Material(
          color: AgrisellColors.surface.withValues(alpha: 0.26),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _HeaderChatButton extends StatelessWidget {
  const _HeaderChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open messages',
      child: SizedBox.square(
        dimension: 36,
        child: Material(
          color: AgrisellColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: const Center(
              child: Icon(
                Icons.sms_rounded,
                size: 22,
                color: AgrisellColors.authGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
