import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_tickets_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/create_support_ticket_screen.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_ticket_detail_screen.dart';
import 'package:agresell_app/features/shared/support/presentation/styles/support_center_styles.dart';
import 'package:agresell_app/features/shared/support/presentation/widgets/support_center_empty_state.dart';
import 'package:agresell_app/features/shared/support/presentation/widgets/support_center_error_state.dart';
import 'package:agresell_app/features/shared/support/presentation/widgets/support_center_header.dart';
import 'package:agresell_app/features/shared/support/presentation/widgets/support_ticket_card.dart';

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({
    this.controller,
    this.openCreateWithCategory,
    super.key,
  });

  final SupportTicketsController? controller;
  final SupportTicketCategory? openCreateWithCategory;

  @override
  State<SupportCenterScreen> createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen> {
  late final SupportTicketsController _controller;
  late final bool _ownsController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? SupportTicketsController();
    unawaited(_controller.loadTickets());

    if (widget.openCreateWithCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openCreateTicket(initialCategory: widget.openCreateWithCategory);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _openCreateTicket({
    SupportTicketCategory? initialCategory,
    SupportTicketPriority? initialPriority,
  }) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => CreateSupportTicketScreen(
          controller: _controller,
          initialCategory: initialCategory,
          initialPriority: initialPriority,
        ),
      ),
    );
  }

  void _openTicketDetail(SupportTicket ticket) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => SupportTicketDetailScreen(
          ticket: ticket,
          ticketsController: _controller,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SupportCenterStyles.screenBackground,
      appBar: AppBar(
        title: const Text(
          'Customer Support',
          style: SupportCenterStyles.appBarTitleStyle,
        ),
        backgroundColor: SupportCenterStyles.appBarBackground,
        foregroundColor: SupportCenterStyles.appBarForeground,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => unawaited(_controller.loadTickets()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SupportCenterStyles.fabBackground,
        foregroundColor: SupportCenterStyles.fabForeground,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text(
          'Open Ticket',
          style: SupportCenterStyles.fabTextStyle,
        ),
        onPressed: () => _openCreateTicket(),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Column(
            children: [
              SupportCenterHeader(
                searchController: _searchController,
                selectedFilter: _controller.filter,
                onSearchChanged: _controller.setSearch,
                onFilterChanged: _controller.setFilter,
              ),
              Expanded(
                child: RefreshIndicator(
                  color: SupportCenterStyles.indicatorColor,
                  onRefresh: _controller.loadTickets,
                  child: _buildBody(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.tickets.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: SupportCenterStyles.indicatorColor,
        ),
      );
    }

    if (_controller.errorMessage != null && _controller.tickets.isEmpty) {
      return SupportCenterErrorState(
        errorMessage: _controller.errorMessage!,
        onRetry: _controller.loadTickets,
      );
    }

    final filtered = _controller.filteredTickets;

    if (filtered.isEmpty) {
      final isSearchingOrFiltering =
          _controller.search.isNotEmpty || _controller.filter != 'all';

      return SupportCenterEmptyState(
        isSearchingOrFiltering: isSearchingOrFiltering,
        onOpenCreateTicket: () => _openCreateTicket(),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: SupportCenterStyles.listPadding,
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final ticket = filtered[index];
        return SupportTicketCard(
          ticket: ticket,
          onTap: () => _openTicketDetail(ticket),
        );
      },
    );
  }
}
