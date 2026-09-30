import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/auth_dashboard_router.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_background.dart';
import 'package:agresell_app/features/auth/presentation/widgets/logo_header.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({this.supabaseInitialization, super.key});

  final Future<bool>? supabaseInitialization;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _didStartTransition = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didStartTransition) {
      return;
    }

    _didStartTransition = true;
    unawaited(_resolveLaunchDestination());
  }

  Future<void> _resolveLaunchDestination() async {
    try {
      unawaited(AuthBackground.precache(context));
      final supabaseInitialization = widget.supabaseInitialization;
      if (supabaseInitialization != null) {
        await supabaseInitialization.timeout(
          const Duration(seconds: 4),
          onTimeout: () => false,
        );
      }
      if (!mounted) return;
      final session = await AuthSessionService.instance.restore().timeout(
        const Duration(seconds: 4),
        onTimeout: AuthSessionRestoreResult.noSession,
      );
      final account = session.account;
      if (!mounted) return;
      if (account != null && account.assignedRole == null) {
        await AuthSessionService.instance.clear();
      }
      if (!mounted) return;
      final destination = account == null
          ? LoginScreen(
              initialMessage: session.wasExpired
                  ? 'Your session has expired. Please log in again.'
                  : null,
            )
          : AuthDashboardRouter.destinationFor(account);

      await Navigator.of(context).pushReplacement(
        agrisellPageRoute<void>(
          builder: (_) => destination,
          beginOffset: Offset.zero,
          duration: const Duration(milliseconds: 350),
          reverseDuration: const Duration(milliseconds: 350),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        agrisellPageRoute<void>(
          builder: (_) => const LoginScreen(),
          beginOffset: Offset.zero,
          duration: const Duration(milliseconds: 350),
          reverseDuration: const Duration(milliseconds: 350),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgrisellColors.forestSoft,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LogoHeader(
              style: LogoHeaderStyle.logoOnly,
              widthMin: 180,
              widthMax: 220,
            ),
            SizedBox(height: 28),
            _SplashLoadingDots(),
          ],
        ),
      ),
    );
  }
}

class _SplashLoadingDots extends StatefulWidget {
  const _SplashLoadingDots();

  @override
  State<_SplashLoadingDots> createState() => _SplashLoadingDotsState();
}

class _SplashLoadingDotsState extends State<_SplashLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: CustomPaint(
        size: const Size(55, 15),
        painter: _SplashLoadingDotsPainter(animation: _controller),
      ),
    );
  }
}

class _SplashLoadingDotsPainter extends CustomPainter {
  _SplashLoadingDotsPainter({required this.animation})
    : super(repaint: animation);

  static const _fadedOpacity = 0x22 / 0xFF;
  static const _radius = 7.5;

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final paint = Paint();
    final opacities = <double>[
      _keyframeValue(progress, const [_fadedOpacity, _fadedOpacity, 1, 1]),
      _keyframeValue(progress, const [1, _fadedOpacity, _fadedOpacity, 1]),
      _keyframeValue(progress, const [1, 1, _fadedOpacity, _fadedOpacity]),
    ];

    for (var index = 0; index < opacities.length; index++) {
      paint.color = Colors.black.withValues(alpha: opacities[index]);
      canvas.drawCircle(
        Offset(_radius + (index * 20), size.height / 2),
        _radius,
        paint,
      );
    }
  }

  static double _keyframeValue(double progress, List<double> values) {
    final scaled = progress * 3;
    final segment = progress >= 1 ? 2 : scaled.floor();
    final segmentProgress = scaled - segment;
    return values[segment] +
        ((values[segment + 1] - values[segment]) * segmentProgress);
  }

  @override
  bool shouldRepaint(covariant _SplashLoadingDotsPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
