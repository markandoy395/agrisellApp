import 'dart:async';
import 'package:agresell_app/core/utils/async_request_scope.dart';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/support/data/support_ticket_repository.dart';
import 'package:agresell_app/features/shared/support/data/supabase_support_ticket_repository.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_error_message.dart';

class SupportTicketsController extends ChangeNotifier {
  SupportTicketsController({SupportTicketRepository? repository})
    : _repository = repository ?? _defaultRepository();

  final SupportTicketRepository _repository;
  final _scope = AsyncRequestScope();

  List<SupportTicket> _tickets = const [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _filter = 'all'; // 'all', 'open', 'resolved'
  String _search = '';

  List<SupportTicket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String get filter => _filter;
  String get search => _search;

  List<SupportTicket> get filteredTickets {
    var result = switch (_filter) {
      'open' => _tickets.where((t) => t.status.isOpen).toList(),
      'resolved' => _tickets.where((t) => t.status.isTerminal).toList(),
      _ => _tickets,
    };

    if (_search.trim().isNotEmpty) {
      final q = _search.trim().toLowerCase();
      result = result.where((t) {
        return t.ticketNumber.toLowerCase().contains(q) ||
            t.subject.toLowerCase().contains(q) ||
            t.category.label.toLowerCase().contains(q) ||
            (t.lastMessage?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return result;
  }

  void setFilter(String filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void setSearch(String query) {
    if (_search == query) return;
    _search = query;
    notifyListeners();
  }

  Future<void> loadTickets() async {
    if (_isLoading) return;
    final ticket = _scope.begin('load');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final values = await _repository.getMyTickets();
      if (ticket.isCurrent) _tickets = values;
    } catch (e) {
      if (!ticket.isCurrent) return;
      _errorMessage = supportErrorMessage(
        e,
        fallback: 'Could not load support tickets. Please try again.',
      );
    } finally {
      _isLoading = false;
      if (ticket.isActive) notifyListeners();
    }
  }

  Future<SupportTicket?> createTicket({
    required String subject,
    required SupportTicketCategory category,
    required String message,
    SupportTicketPriority priority = SupportTicketPriority.medium,
    int? orderId,
    int? deliveryId,
  }) async {
    if (_isSubmitting) return null;
    final ticket = _scope.begin('create');
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createTicket(
        subject: subject,
        category: category,
        message: message,
        priority: priority,
        orderId: orderId,
        deliveryId: deliveryId,
      );

      if (!ticket.isCurrent) return null;
      _scope.invalidate('load');
      _tickets = [
        created,
        ..._tickets.where((t) => t.ticketId != created.ticketId),
      ];
      return created;
    } catch (e) {
      if (!ticket.isCurrent) return null;
      _errorMessage = supportErrorMessage(
        e,
        fallback: 'Could not submit your ticket. Please try again.',
      );
      return null;
    } finally {
      _isSubmitting = false;
      if (ticket.isCurrent) notifyListeners();
    }
  }

  void updateTicketInList(SupportTicket updated) {
    final idx = _tickets.indexWhere((t) => t.ticketId == updated.ticketId);
    if (idx != -1) {
      final list = [..._tickets];
      list[idx] = updated;
      _tickets = list;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  static SupportTicketRepository _defaultRepository() {
    if (AgrisellSupabase.isInitialized &&
        AgrisellSupabase.client.auth.currentUser != null) {
      return SupabaseSupportTicketRepository();
    }
    return InMemorySupportTicketRepository();
  }
}
