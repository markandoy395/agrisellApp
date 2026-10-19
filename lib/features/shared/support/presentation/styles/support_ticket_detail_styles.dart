import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/styles/support_ticket_badge_styles.dart';
import 'package:agresell_app/features/shared/support/presentation/styles/support_ticket_composer_styles.dart';

export 'package:agresell_app/features/shared/support/presentation/styles/support_ticket_badge_styles.dart';
export 'package:agresell_app/features/shared/support/presentation/styles/support_ticket_composer_styles.dart';

abstract final class SupportTicketDetailStyles {
  static const background = AgrisellColors.homeBackground;
  static const surface = AgrisellColors.surface;
  static const heading = AgrisellColors.headingGreen;
  static const green = AgrisellColors.forestGreen;
  static const muted = AgrisellColors.mutedText;
  static const white = Colors.white;
  static const avatarBackground = AgrisellColors.forestSoft;
  static const reopenColor = AgrisellColors.statusOrangeText;
  static const errorBackground = AgrisellColors.unavailableRed;

  static const ticketNumber = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 15,
    fontFamily: AppTypography.fontFamily,
  );
  static const userMessage = TextStyle(
    fontSize: 14,
    color: Colors.white,
    height: 1.35,
  );
  static const supportMessage = TextStyle(
    fontSize: 14,
    color: AgrisellColors.brandBlack,
    height: 1.35,
  );

  static const header = BoxDecoration(
    color: AgrisellColors.surface,
    border: Border(bottom: BorderSide(color: AgrisellColors.borderLine)),
  );

  static final resolutionNotes = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AgrisellColors.forestGreen.withValues(alpha: 0.2),
    ),
  );

  static const categoryLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.mutedText,
  );

  static const subject = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.headingGreen,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
  );

  static const resolutionText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.forestGreen,
  );

  static const headerPadding = EdgeInsets.fromLTRB(16, 12, 16, 12);
  static const systemPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 4,
  );
  static const messageMargin = EdgeInsets.symmetric(vertical: 6);
  static const senderPadding = EdgeInsets.only(left: 4, bottom: 2);
  static const timestampPadding = EdgeInsets.only(top: 3, left: 4, right: 4);
  static const errorPadding = EdgeInsets.all(24);
  static const threadPadding = EdgeInsets.fromLTRB(16, 12, 16, 16);
  static const threadError = TextStyle(
    fontSize: 14,
    color: AgrisellColors.mutedText,
  );
  static const resolutionPadding = EdgeInsets.all(10);

  static final userBubble = _bubble(true);
  static final supportBubble = _bubble(false);
  static BoxDecoration _bubble(bool isUser) => BoxDecoration(
    color: isUser ? AgrisellColors.forestGreen : AgrisellColors.surface,
    borderRadius: BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isUser
          ? const Radius.circular(4)
          : const Radius.circular(16),
    ),
    border: isUser ? null : Border.all(color: AgrisellColors.borderLine),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final systemBubble = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const systemMessage = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    fontStyle: FontStyle.italic,
  );

  static const senderName = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.mutedText,
  );

  static const messageTime = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
  );

  static const systemMargin = EdgeInsets.symmetric(vertical: 8);
  static const bubbleUserMargin = EdgeInsets.only(left: 48, bottom: 8);
  static const bubbleSupportMargin = EdgeInsets.only(right: 48, bottom: 8);
  static const bubblePadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static const emptyStatePadding = EdgeInsets.all(32);
  static const avatarSize = 14.0;
  static const retryButtonPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );

  static final retryButton = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.forestGreen,
    foregroundColor: Colors.white,
    padding: retryButtonPadding,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final statusPending = BoxDecoration(
    color: AgrisellColors.statusOrangeBackground,
    borderRadius: BorderRadius.circular(16),
  );

  static const statusPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 3,
  );
  static const priorityPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 3,
  );

  // Delegated Badge Styles
  static BoxDecoration statusSurface(SupportTicketStatus status) =>
      SupportTicketBadgeStyles.statusSurface(status);
  static BoxDecoration prioritySurface(SupportTicketPriority priority) =>
      SupportTicketBadgeStyles.prioritySurface(priority);
  static TextStyle statusText(SupportTicketStatus status) =>
      SupportTicketBadgeStyles.statusText(status);
  static TextStyle priorityText(SupportTicketPriority priority) =>
      SupportTicketBadgeStyles.priorityText(priority);

  // Delegated Composer Styles
  static const composer = SupportTicketComposerStyles.composer;
  static const composerPadding = SupportTicketComposerStyles.composerPadding;
  static const reopenPadding = SupportTicketComposerStyles.reopenPadding;
  static const reopenNote = SupportTicketComposerStyles.reopenNote;
  static InputDecoration get replyInput =>
      SupportTicketComposerStyles.replyInput;
  static ButtonStyle get sendButton => SupportTicketComposerStyles.sendButton;
}
