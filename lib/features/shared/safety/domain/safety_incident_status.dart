enum SafetyIncidentStatus {
  submitted,
  underReview,
  waitingForInformation,
  escalated,
  resolved,
  rejected;

  String get label => switch (this) {
    submitted => 'Pending Review',
    underReview => 'Under Investigation',
    waitingForInformation => 'Waiting for Info',
    escalated => 'Escalated',
    resolved => 'Resolved',
    rejected => 'Dismissed',
  };

  bool get isTerminal => this == resolved || this == rejected;
  bool get isOpen => !isTerminal;

  static SafetyIncidentStatus fromString(String value) {
    for (final status in values) {
      if (status.name.toLowerCase() == value.toLowerCase()) return status;
    }
    return switch (value.toLowerCase()) {
      'open' => submitted,
      'under_review' => underReview,
      'waiting_for_info' || 'waiting_for_information' => waitingForInformation,
      'closed' => resolved,
      _ => submitted,
    };
  }
}
