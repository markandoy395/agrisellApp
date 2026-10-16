import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';
import '../../domain/rider_communication_models.dart';

abstract final class RiderMessagingDesignStyles {
  static const background = AgrisellColors.pageBackground;
  static const radius = BorderRadius.all(Radius.circular(16));
  static const filterShape = StadiumBorder();
  static final heading = AppTypography.title.copyWith(
    fontSize: 25,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.headingGreen,
  );
  static final title = AppTypography.title.copyWith(
    fontWeight: FontWeight.w600,
    color: AgrisellColors.headingGreen,
  );
  static final body = AppTypography.body.copyWith(
    color: AgrisellColors.headingGreen,
    height: 1.5,
  );
  static final muted = AppTypography.body.copyWith(
    color: AgrisellColors.mutedText,
  );
  static final caption = AppTypography.caption.copyWith(
    color: AgrisellColors.mutedText,
  );
  static final section = AppTypography.caption.copyWith(
    color: AgrisellColors.mutedText,
    letterSpacing: 1.5,
    fontWeight: FontWeight.w600,
  );
  static final badgeText = AppTypography.caption.copyWith(
    color: AgrisellColors.surface,
    fontWeight: FontWeight.w600,
  );
  static final card = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: radius,
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static final protected = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: radius,
    border: Border.all(
      color: AgrisellColors.deliveryGreen.withValues(alpha: .3),
    ),
  );
  static final warning = BoxDecoration(
    color: AgrisellColors.accentOrange.withValues(alpha: .12),
    borderRadius: radius,
    border: Border.all(
      color: AgrisellColors.accentOrange.withValues(alpha: .4),
    ),
  );
  static const badge = BoxDecoration(
    color: AgrisellColors.authGreen,
    shape: BoxShape.circle,
  );
  static Color avatarColor(RiderConversationParty party) => switch (party) {
    RiderConversationParty.seller => AgrisellColors.forestSoft,
    RiderConversationParty.buyer => AgrisellColors.accentBlue.withValues(
      alpha: .18,
    ),
    RiderConversationParty.support => AgrisellColors.limeSoft,
  };
  static final quickButton = OutlinedButton.styleFrom(
    minimumSize: const Size(64, 40),
    maximumSize: Size.infinite,
    foregroundColor: AgrisellColors.authGreen,
    backgroundColor: AgrisellColors.forestSoft,
    side: BorderSide.none,
    shape: const StadiumBorder(),
    textStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  );
  static final replyButton = OutlinedButton.styleFrom(
    minimumSize: const Size(64, 58),
    maximumSize: Size.infinite,
    foregroundColor: AgrisellColors.headingGreen,
    backgroundColor: background,
    side: const BorderSide(color: AgrisellColors.borderLine),
    shape: const RoundedRectangleBorder(borderRadius: radius),
    textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    alignment: Alignment.centerLeft,
  );
  static final selectedReplyButton = replyButton.copyWith(
    backgroundColor: const WidgetStatePropertyAll(AgrisellColors.forestSoft),
    side: const WidgetStatePropertyAll(
      BorderSide(color: AgrisellColors.authGreen, width: 2),
    ),
  );
  static final sendButton = FilledButton.styleFrom(
    minimumSize: const Size(64, 52),
    maximumSize: Size.infinite,
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: radius),
    padding: const EdgeInsets.symmetric(vertical: 16),
    textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
  );
}
