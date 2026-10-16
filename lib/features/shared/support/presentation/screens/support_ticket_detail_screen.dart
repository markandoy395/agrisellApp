import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/support/data/support_ticket_repository.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_ticket_detail_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_tickets_controller.dart';

import '../styles/support_ticket_detail_styles.dart';
import '../widgets/support_ticket_detail_header.dart';
import '../widgets/support_message_thread.dart';
import '../widgets/support_reply_composer.dart';

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
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Failed to send reply.'),
          backgroundColor: SupportTicketDetailStyles.errorBackground,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => Scaffold(
      backgroundColor: SupportTicketDetailStyles.background,
      appBar: AppBar(
        title: Text(
          _controller.ticket.ticketNumber,
          style: SupportTicketDetailStyles.ticketNumber,
        ),
        backgroundColor: SupportTicketDetailStyles.surface,
        foregroundColor: SupportTicketDetailStyles.heading,
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
          SupportTicketDetailHeader(ticket: _controller.ticket),
          Expanded(
            child: SupportMessageThread(
              controller: _controller,
              scrollController: _scrollController,
            ),
          ),
          SupportReplyComposer(
            ticket: _controller.ticket,
            replyController: _replyTextController,
            isSending: _controller.isSending,
            onSend: _sendReply,
          ),
        ],
      ),
    ),
  );
}
