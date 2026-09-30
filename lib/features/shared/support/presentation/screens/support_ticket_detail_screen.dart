import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/support/data/support_ticket_repository.dart';
import 'package:agresell_app/features/shared/support/domain/support_message.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_ticket_detail_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_tickets_controller.dart';

class SupportTicketDetailScreen extends StatefulWidget {
  const SupportTicketDetailScreen({
    required this.ticket,
    this.ticketsController,
    this.detailController,
    this.repository,
    super.key,
  });

  final SupportTicket ticket;
  final SupportTicketsController? ticketsController;
  final SupportTicketDetailController? detailController;
  final SupportTicketRepository? repository;

  @override
  State<SupportTicketDetailScreen> createState() =>
      _SupportTicketDetailScreenState();
}

class _SupportTicketDetailScreenState extends State<SupportTicketDetailScreen> {
  late final SupportTicketDetailController _controller;
  late final bool _ownsController;
  final TextEditingController _replyTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.detailController == null;
    _controller =
        widget.detailController ??
        SupportTicketDetailController(
          ticket: widget.ticket,
          repository: widget.repository,
        );
    unawaited(_controller.loadMessages());
  }

  @override
  void dispose() {
    _replyTextController.dispose();
    _scrollController.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendReply() async {
    final text = _replyTextController.text.trim();
    if (text.isEmpty) return;

    _replyTextController.clear();
    final success = await _controller.sendMessage(text);

    if (success) {
      widget.ticketsController?.updateTicketInList(_controller.ticket);
      _scrollToBottom();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Failed to send reply.'),
          backgroundColor: AgrisellColors.unavailableRed,
        ),
      );
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final ticket = _controller.ticket;
        final messages = _controller.messages;

        return Scaffold(
          backgroundColor: AgrisellColors.homeBackground,
          appBar: AppBar(
            title: Text(
              ticket.ticketNumber,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                fontFamily: 'monospace',
              ),
            ),
            backgroundColor: AgrisellColors.surface,
            foregroundColor: AgrisellColors.headingGreen,
            elevation: 0,
            actions: [
              IconButton(
                tooltip: 'Refresh Thread',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => unawaited(_controller.loadMessages()),
              ),
            ],
          ),
          body: Column(
            children: [
              // Ticket Header Card
              _buildTicketHeader(ticket),

              // Messages Thread
              Expanded(
                child: _controller.isLoading && messages.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AgrisellColors.forestGreen,
                        ),
                      )
                    : RefreshIndicator(
                        color: AgrisellColors.forestGreen,
                        onRefresh: _controller.loadMessages,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            return _buildMessageBubble(msg);
                          },
                        ),
                      ),
              ),

              // Bottom Reply Composer
              _buildReplyComposer(ticket),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketHeader(SupportTicket ticket) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        border: Border(bottom: BorderSide(color: AgrisellColors.borderLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category Icon & Label
              Icon(ticket.category.icon, size: 16, color: AgrisellColors.mutedText),
              const SizedBox(width: 4),
              Text(
                ticket.category.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AgrisellColors.mutedText,
                ),
              ),
              const Spacer(),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: ticket.status.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  ticket.status.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ticket.status.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Priority Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ticket.priority.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ticket.priority.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ticket.priority.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.subject,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AgrisellColors.headingGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Created on ${_formatDateTime(ticket.createdAt)}',
            style: const TextStyle(
              fontSize: 12,
              color: AgrisellColors.mutedText,
            ),
          ),
          if (ticket.resolutionNotes != null &&
              ticket.resolutionNotes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AgrisellColors.forestSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AgrisellColors.forestGreen.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: AgrisellColors.forestGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Resolution Notes: ${ticket.resolutionNotes}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AgrisellColors.forestGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportMessage msg) {
    if (msg.senderRole.isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AgrisellColors.searchBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AgrisellColors.borderLine),
            ),
            child: Text(
              msg.body,
              style: const TextStyle(
                fontSize: 12,
                color: AgrisellColors.mutedText,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final isUser = msg.senderRole.isFromCustomer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AgrisellColors.forestSoft,
              child: const Icon(
                Icons.support_agent_rounded,
                size: 18,
                color: AgrisellColors.forestGreen,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      msg.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AgrisellColors.mutedText,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AgrisellColors.forestGreen
                        : AgrisellColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: AgrisellColors.borderLine),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : AgrisellColors.brandBlack,
                      height: 1.35,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                  child: Text(
                    _formatDateTime(msg.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AgrisellColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildReplyComposer(SupportTicket ticket) {
    return Container(
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        border: Border(top: BorderSide(color: AgrisellColors.borderLine)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ticket.status.isTerminal)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 4),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: AgrisellColors.statusOrangeText,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Replying will automatically re-open this ticket.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AgrisellColors.statusOrangeText,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyTextController,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type your reply here...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: AgrisellColors.mutedText,
                        ),
                        filled: true,
                        fillColor: AgrisellColors.searchBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendReply(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _controller.isSending ? null : _sendReply,
                    style: IconButton.styleFrom(
                      backgroundColor: AgrisellColors.forestGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: _controller.isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
