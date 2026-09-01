enum RiderSignUpStep {
  account('Account credentials'),
  personal('Personal information'),
  address('Address and exact location'),
  vehicle('Vehicle information'),
  documents('Driver information'),
  review('Review and submit');

  const RiderSignUpStep(this.title);
  final String title;
}

enum RiderDraftDocumentType {
  profilePhoto('Profile picture'),
  driversLicense('Driver’s license'),
  validId('Valid government ID'),
  vehicleOr('Vehicle official receipt'),
  vehicleCr('Vehicle registration certificate'),
  vehiclePhoto('Vehicle photo');

  const RiderDraftDocumentType(this.label);
  final String label;
}

enum RiderDocumentStatus {
  ready('Ready to submit'),
  submitted('Submitted'),
  approved('Approved'),
  rejected('Rejected'),
  resubmissionRequired('Resubmission required');

  const RiderDocumentStatus(this.label);
  final String label;
}

class RiderDraftDocument {
  const RiderDraftDocument({
    required this.path,
    required this.fileName,
    this.progress = 1,
    this.status = RiderDocumentStatus.ready,
  });

  final String path;
  final String fileName;
  final double progress;
  final RiderDocumentStatus status;

  RiderDraftDocument copyWith({
    double? progress,
    RiderDocumentStatus? status,
  }) => RiderDraftDocument(
    path: path,
    fileName: fileName,
    progress: progress ?? this.progress,
    status: status ?? this.status,
  );

  Map<String, Object> toJson() => {
    'path': path,
    'fileName': fileName,
    'progress': progress,
    'status': status.name,
  };

  factory RiderDraftDocument.fromJson(Map<String, Object?> json) {
    final statusName = json['status'];
    return RiderDraftDocument(
      path: json['path'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 1,
      status: RiderDocumentStatus.values.firstWhere(
        (item) => item.name == statusName,
        orElse: () => RiderDocumentStatus.ready,
      ),
    );
  }
}

class RiderSignUpDraft {
  const RiderSignUpDraft({
    this.step = RiderSignUpStep.account,
    this.values = const {},
    this.documents = const {},
    this.acceptsTerms = false,
    this.acceptsPrivacy = false,
    this.confirmsAccuracy = false,
  });

  final RiderSignUpStep step;
  final Map<String, String> values;
  final Map<RiderDraftDocumentType, RiderDraftDocument> documents;
  final bool acceptsTerms;
  final bool acceptsPrivacy;
  final bool confirmsAccuracy;

  String value(String key) => values[key] ?? '';

  RiderSignUpDraft withValue(String key, String value) =>
      copyWith(values: {...values, key: value});

  RiderSignUpDraft withDocument(
    RiderDraftDocumentType type,
    RiderDraftDocument? document,
  ) {
    final nextDocuments = {...documents};
    if (document == null) {
      nextDocuments.remove(type);
    } else {
      nextDocuments[type] = document;
    }
    return copyWith(documents: nextDocuments);
  }

  RiderSignUpDraft copyWith({
    RiderSignUpStep? step,
    Map<String, String>? values,
    Map<RiderDraftDocumentType, RiderDraftDocument>? documents,
    bool? acceptsTerms,
    bool? acceptsPrivacy,
    bool? confirmsAccuracy,
  }) => RiderSignUpDraft(
    step: step ?? this.step,
    values: values ?? this.values,
    documents: documents ?? this.documents,
    acceptsTerms: acceptsTerms ?? this.acceptsTerms,
    acceptsPrivacy: acceptsPrivacy ?? this.acceptsPrivacy,
    confirmsAccuracy: confirmsAccuracy ?? this.confirmsAccuracy,
  );

  Map<String, Object> toJson() => {
    'flowVersion': 2,
    'step': step.name,
    'values': values,
    'documents': {
      for (final entry in documents.entries)
        entry.key.name: entry.value.toJson(),
    },
    'acceptsTerms': acceptsTerms,
    'acceptsPrivacy': acceptsPrivacy,
    'confirmsAccuracy': confirmsAccuracy,
  };

  factory RiderSignUpDraft.fromJson(Map<String, Object?> json) {
    final rawStep = json['step'];
    final restoredStep = rawStep is String
        ? RiderSignUpStep.values.firstWhere(
            (step) => step.name == rawStep,
            orElse: () => RiderSignUpStep.account,
          )
        // Version 1 stored enum indexes from the old personal-first flow. A
        // password was never persisted, so every legacy draft safely resumes
        // at the new credentials step while retaining its non-sensitive data.
        : RiderSignUpStep.account;
    return RiderSignUpDraft(
      step: restoredStep,
      values: _stringMap(json['values']),
      documents: _documents(json['documents']),
      acceptsTerms: json['acceptsTerms'] as bool? ?? false,
      acceptsPrivacy: json['acceptsPrivacy'] as bool? ?? false,
      confirmsAccuracy: json['confirmsAccuracy'] as bool? ?? false,
    );
  }
}

Map<String, String> _stringMap(Object? raw) => raw is Map
    ? {
        for (final entry in raw.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String,
      }
    : const {};

Map<RiderDraftDocumentType, RiderDraftDocument> _documents(Object? raw) {
  if (raw is! Map) return const {};
  final documents = <RiderDraftDocumentType, RiderDraftDocument>{};
  for (final entry in raw.entries) {
    if (entry.key is! String || entry.value is! Map) continue;
    final type = RiderDraftDocumentType.values.where(
      (item) => item.name == entry.key,
    );
    if (type.isEmpty) continue;
    documents[type.first] = RiderDraftDocument.fromJson(
      _objectMap(entry.value),
    );
  }
  return documents;
}

Map<String, Object?> _objectMap(Object raw) => raw is Map
    ? {
        for (final entry in raw.entries)
          if (entry.key is String) entry.key as String: entry.value,
      }
    : const {};
