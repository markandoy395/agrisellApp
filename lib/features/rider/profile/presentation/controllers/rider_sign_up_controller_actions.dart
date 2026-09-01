part of 'rider_sign_up_controller.dart';

extension RiderSignUpControllerActions on RiderSignUpController {
  bool validateForSubmission() {
    for (final step in RiderSignUpStep.values) {
      final error = RiderSignUpValidator.stepError(
        draft: _draft,
        step: step,
        licenseNumber: _licenseNumber,
        password: _password,
        confirmPassword: _confirmPassword,
        requirePassword: !emailVerified,
      );
      if (error == null) continue;
      _error = error;
      _draft = _draft.copyWith(step: step);
      _showStepErrors = true;
      _refresh();
      return false;
    }
    return true;
  }

  Future<void> addDocument(
    RiderDraftDocumentType type,
    ImageSource source,
  ) async {
    try {
      final document = await _documents.pick(type: type, source: source);
      if (document == null) return;
      await _documents.remove(_draft.documents[type]);
      _draft = _draft.withDocument(type, document);
      _error = null;
      await saveNow();
    } on RiderDocumentUploadException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'The document could not be saved. Please try again.';
    }
    _refresh();
  }

  Future<void> removeDocument(RiderDraftDocumentType type) async {
    await _documents.remove(_draft.documents[type]);
    _draft = _draft.withDocument(type, null);
    await saveNow();
    _refresh();
  }

  Future<RiderProfile?> submit() async {
    if (_submitting) return null;
    if (!validateForSubmission()) return null;
    _submitting = true;
    _error = null;
    _awaitingEmailOtp = false;
    _refresh();
    try {
      final profile = await _submissionService.submit(
        draft: _draft,
        licenseNumber: _licenseNumber,
        password: _password,
        confirmPassword: _confirmPassword,
        emailAlreadyVerified: emailVerified,
        onUploadProgress: (type, progress) {
          final document = _draft.documents[type];
          if (document == null) return;
          _draft = _draft.withDocument(
            type,
            document.copyWith(
              progress: progress,
              status: progress >= 1
                  ? RiderDocumentStatus.submitted
                  : RiderDocumentStatus.ready,
            ),
          );
          _queueSave();
          _refresh();
        },
      );
      for (final document in _draft.documents.values) {
        await _documents.remove(document);
      }
      await _storage.clear();
      return profile;
    } on RiderEmailOtpRequired catch (error) {
      _awaitingEmailOtp = true;
      _error = error.message;
    } on RiderRegistrationException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Your Rider application could not be submitted. Please retry.';
    } finally {
      _submitting = false;
      _refresh();
    }
    return null;
  }

  Future<void> saveNow() async {
    _saveTimer?.cancel();
    await _storage.save(_draft);
  }

  Future<void> discard() async {
    _saveTimer?.cancel();
    for (final document in _draft.documents.values) {
      await _documents.remove(document);
    }
    await _storage.clear();
    _draft = const RiderSignUpDraft();
    _password = '';
    _confirmPassword = '';
    _licenseNumber = '';
    _verifiedEmail = null;
  }
}
