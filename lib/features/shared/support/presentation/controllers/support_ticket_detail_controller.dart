import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/support/data/support_ticket_repository.dart';
import 'package:agresell_app/features/shared/support/data/supabase_support_ticket_repository.dart';
import 'package:agresell_app/features/shared/support/domain/support_message.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';

class SupportTicketDetailController extends ChangeNotifier {
  SupportTicketDetailController({
    required SupportTicket ticket,
    SupportTicketRepository? repository,
  }) : _ticket = ticket,
       _repository = repository ?? _defaultRepository();

  SupportTicket _ticket;
  final SupportTicketRepository _repository;

  List<SupportMessage> _messages = const [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  SupportTicket get ticket => _ticket;
  List<SupportMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  Future<void> loadMessages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _messages = await _repository.getTicketMessages(_ticket.ticketId);
    } catch (e) {
      _errorMessage = 'Could not load messages: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newMsg = await _repository.sendMessage(
        ticketId: _ticket.ticketId,
        body: trimmed,
      );

      _messages = [..._messages, newMsg];

      // Update ticket status: If ticket was resolved/closed, it re-opens to 'open'
      if (_ticket.status.isTerminal) {
        _ticket = _ticket.copyWith(
          status: SupportTicketStatus.open,
          lastMessage: trimmed,
          updatedAt: DateTime.now(),
        );
      } else {
        _ticket = _ticket.copyWith(
          lastMessage: trimmed,
          updatedAt: DateTime.now(),
        );
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  static SupportTicketRepository _defaultRepository() {
    if (AgrisellSupabase.isInitialized &&
        AgrisellSupabase.client.auth.currentUser != null) {
      return SupabaseSupportTicketRepository();
    }
    return InMemorySupportTicketRepository();
  }
}
