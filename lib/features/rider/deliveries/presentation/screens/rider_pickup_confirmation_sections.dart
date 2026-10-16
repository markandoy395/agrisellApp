part of 'rider_pickup_confirmation_screen.dart';

extension _PickupConfirmationSections on _RiderPickupConfirmationScreenState {
  Widget _summary() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      RiderPickupSummaryCard(request: widget.request),
      const SizedBox(height: 12),
      RiderPickupInstructionsCard(
        request: widget.request,
        waitingStartedAt: widget.controller.pickupWaitingStartedAt,
      ),
      const SizedBox(height: 16),
      _locationStatus(),
    ],
  );

  Widget _checklist() => RiderDetailSection(
    title: 'Product condition checklist',
    icon: Icons.fact_check_outlined,
    children: [
      for (final label in _checkLabels)
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AgrisellColors.authGreen,
          title: Text(label, style: RiderPickupDesignStyles.body),
          value: _checks[label] ?? false,
          onChanged: _busy ? null : (value) => _setCheck(label, value ?? false),
        ),
    ],
  );

  Widget _action(PickupConfiguration config) => LayoutBuilder(
    builder: (context, constraints) {
      final report = OutlinedButton.icon(
        style: RiderPickupDesignStyles.secondary,
        onPressed: _busy ? null : _reportProblem,
        icon: const Icon(Icons.report_problem_rounded, size: 19),
        label: const Text('Report pickup problem'),
      );
      final complete = FilledButton.icon(
        style: RiderPickupDesignStyles.primary,
        onPressed: _busy ? null : () => _submit(config),
        icon: _submitting || _capturing
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AgrisellColors.surface,
                ),
              )
            : const Icon(Icons.check_rounded, size: 19),
        label: Text(_submitting ? 'Confirming...' : 'Complete pickup'),
      );
      if (constraints.maxWidth < 340 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.2) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [report, const SizedBox(height: 8), complete],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: report),
          const SizedBox(width: 10),
          Expanded(child: complete),
        ],
      );
    },
  );
}
