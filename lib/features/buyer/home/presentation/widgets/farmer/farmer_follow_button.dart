import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/buyer/home/data/farmer_follow_repository.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/farmer_follow_controller.dart';

class FarmerFollowButton extends StatelessWidget {
  const FarmerFollowButton({
    required this.farmer,
    this.controller,
    this.compact = false,
    this.onDarkBackground = false,
    super.key,
  });

  final FarmerProfile farmer;
  final FarmerFollowController? controller;
  final bool compact;
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context) {
    final followController = controller ?? FarmerFollowController.instance;
    return AnimatedBuilder(
      animation: followController,
      builder: (context, _) {
        final state = followController.stateFor(farmer);
        final isBusy = followController.isBusy(farmer.farmId);
        return Semantics(
          button: true,
          label: state.isFollowing
              ? 'Unfollow ${farmer.name}, ${state.followerCount} followers'
              : 'Follow ${farmer.name}, ${state.followerCount} followers',
          child: SizedBox(
            height: compact ? 30 : 38,
            child: state.isFollowing
                ? FilledButton(
                    key: ValueKey('following-${farmer.farmId}'),
                    onPressed: isBusy
                        ? null
                        : () => _toggle(context, followController),
                    style: _filledStyle(),
                    child: _label(state.isFollowing, isBusy),
                  )
                : OutlinedButton(
                    key: ValueKey('follow-${farmer.farmId}'),
                    onPressed: isBusy
                        ? null
                        : () => _toggle(context, followController),
                    style: _outlinedStyle(),
                    child: _label(state.isFollowing, isBusy),
                  ),
          ),
        );
      },
    );
  }

  ButtonStyle _filledStyle() => FilledButton.styleFrom(
    backgroundColor: onDarkBackground
        ? AgrisellColors.surface
        : AgrisellColors.authGreen,
    foregroundColor: onDarkBackground
        ? AgrisellColors.authGreen
        : AgrisellColors.surface,
    disabledBackgroundColor: onDarkBackground
        ? AgrisellColors.surface.withValues(alpha: 0.72)
        : AgrisellColors.authGreen.withValues(alpha: 0.72),
    shape: const StadiumBorder(),
    padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  ButtonStyle _outlinedStyle() => OutlinedButton.styleFrom(
    foregroundColor: onDarkBackground
        ? AgrisellColors.surface
        : AgrisellColors.authGreen,
    side: BorderSide(
      color: onDarkBackground
          ? AgrisellColors.surface
          : AgrisellColors.authGreen,
      width: 1.2,
    ),
    shape: const StadiumBorder(),
    padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  Widget _label(bool isFollowing, bool isBusy) {
    if (isBusy) {
      return SizedBox.square(
        dimension: compact ? 14 : 16,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isFollowing ? Icons.check_rounded : Icons.person_add_alt_1_rounded,
          size: compact ? 15 : 16,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> _toggle(
    BuildContext context,
    FarmerFollowController followController,
  ) async {
    try {
      final state = await followController.toggle(farmer);
      if (!context.mounted) return;
      final message = state.isFollowing
          ? 'You are now following ${farmer.name}.'
          : 'You unfollowed ${farmer.name}.';
      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(SnackBar(content: Text(message)));
    } on FarmerFollowException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
