import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_tickets_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/create_support_ticket_screen.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_ticket_detail_screen.dart';
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
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(
        title: const Text(
          'Customer Support',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        backgroundColor: AgrisellColors.surface,
        foregroundColor: AgrisellColors.headingGreen,
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
        backgroundColor: AgrisellColors.forestGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text(
          'Open Ticket',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () => _openCreateTicket(),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Column(
            children: [
              // Search & Filter Header
              _buildHeader(),

              // Ticket List or States
              Expanded(
                child: RefreshIndicator(
                  color: AgrisellColors.forestGreen,
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

  Widget _buildHeader() {
    return Container(
      color: AgrisellColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Search Input
          TextField(
            controller: _searchController,
            onChanged: _controller.setSearch,
            decoration: InputDecoration(
              hintText: 'Search tickets by subject, #ID, or category...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AgrisellColors.mutedText,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: AgrisellColors.mutedText,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _controller.setSearch('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AgrisellColors.searchBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('all', 'All Tickets'),
                const SizedBox(width: 8),
                _filterChip('open', 'Active / In Progress'),
                const SizedBox(width: 8),
                _filterChip('resolved', 'Resolved / Closed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label) {
    final isSelected = _controller.filter == filterKey;
    return ChoiceChip(
      showCheckmark: false,
      label: Text(label),
      selected: isSelected,
      selectedColor: AgrisellColors.forestGreen,
      backgroundColor: AgrisellColors.searchBackground,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AgrisellColors.headingGreen,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? AgrisellColors.forestGreen
              : AgrisellColors.borderLine,
        ),
      ),
      onSelected: (_) => _controller.setFilter(filterKey),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.tickets.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AgrisellColors.forestGreen),
      );
    }

    if (_controller.errorMessage != null && _controller.tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AgrisellColors.unavailableRed,
              ),
              const SizedBox(height: 12),
              Text(
                _controller.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AgrisellColors.mutedText),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _controller.loadTickets,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _controller.filteredTickets;

    if (filtered.isEmpty) {
      final isSearchingOrFiltering =
          _controller.search.isNotEmpty || _controller.filter != 'all';

      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AgrisellColors.forestSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  size: 38,
                  color: AgrisellColors.forestGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isSearchingOrFiltering
                    ? 'No matching tickets found'
                    : 'No support tickets opened yet',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AgrisellColors.headingGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSearchingOrFiltering
                    ? 'Try adjusting your search terms or filter tab.'
                    : 'Have an inquiry or issue regarding orders, payments, or safety? We are ready to help.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AgrisellColors.mutedText,
                  height: 1.4,
                ),
              ),
              if (!isSearchingOrFiltering) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => _openCreateTicket(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AgrisellColors.forestGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Open Your First Ticket'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 88),
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
