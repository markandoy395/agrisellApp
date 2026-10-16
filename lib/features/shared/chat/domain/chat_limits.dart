import 'package:flutter/services.dart';

/// Shared by every role, quick replies, retries and offline queue admission.
abstract final class ChatLimits {
  static const messageCharacters = 500;
  static const messagesPerConversationMinute = 10;
  static const messagesPerAccountDay = 100;
  static const newConversationsPerDay = 5;
  static const lengthError = 'Messages must contain 1–500 characters.';
  static const minuteError =
      'Conversation limit reached. Try again in a minute.';
  static const dayError = 'Daily message limit reached. Try again tomorrow.';
  static const conversationError =
      'Daily new-conversation limit reached. Try again tomorrow.';

  // Unicode code points match PostgreSQL char_length, including emoji.
  static int length(String text) => text.runes.length;
  static bool valid(String text) =>
      text.trim().isNotEmpty && length(text) <= messageCharacters;
  static final inputFormatter = TextInputFormatter.withFunction((
    oldValue,
    newValue,
  ) {
    if (length(newValue.text) <= messageCharacters ||
        length(newValue.text) < length(oldValue.text)) {
      return newValue;
    }
    return oldValue;
  });

  static String? serverError(String? code) => switch (code) {
    'PT429' || '429' => 'Chat limit reached. Please wait before trying again.',
    '22001' => lengthError,
    _ => null,
  };
}
