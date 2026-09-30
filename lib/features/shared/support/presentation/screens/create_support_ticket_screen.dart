import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_tickets_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_ticket_detail_screen.dart';

class CreateSupportTicketScreen extends StatefulWidget {
  const CreateSupportTicketScreen({
    this.controller,
    this.initialCategory,
    this.initialPriority,
    this.initialSubject,
    this.initialMessage,
    this.orderId,
    this.deliveryId,
    super.key,
  });

  final SupportTicketsController? controller;
  final SupportTicketCategory? initialCategory;
  final SupportTicketPriority? initialPriority;
  final String? initialSubject;
  final String? initialMessage;
  final int? orderId;
  final int? deliveryId;

  @override
  State<CreateSupportTicketScreen> createState() =>
      _CreateSupportTicketScreenState();
}

class _CreateSupportTicketScreenState extends State<CreateSupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subjectController;
  late final TextEditingController _messageController;
  late final SupportTicketsController _controller;
  late final bool _ownsController;

  late SupportTicketCategory _selectedCategory;
  late SupportTicketPriority _selectedPriority;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? SupportTicketsController();
    _selectedCategory = widget.initialCategory ?? SupportTicketCategory.general;
    _selectedPriority = widget.initialPriority ?? SupportTicketPriority.medium;
    _subjectController = TextEditingController(text: widget.initialSubject ?? '');
    _messageController = TextEditingController(text: widget.initialMessage ?? '');
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final created = await _controller.createTicket(
      subject: _subjectController.text.trim(),
      category: _selectedCategory,
      message: _messageController.text.trim(),
      priority: _selectedPriority,
      orderId: widget.orderId,
      deliveryId: widget.deliveryId,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Support ticket ${created.ticketNumber} created successfully!'),
          backgroundColor: AgrisellColors.forestGreen,
        ),
      );

      // Replace current screen with Detail Screen
      Navigator.of(context).pushReplacement(
        agrisellPageRoute<void>(
          builder: (_) => SupportTicketDetailScreen(
            ticket: created,
            ticketsController: widget.controller,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ?? 'Failed to submit support ticket.',
          ),
          backgroundColor: AgrisellColors.unavailableRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(
        title: const Text(
          'Open Support Ticket',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        backgroundColor: AgrisellColors.surface,
        foregroundColor: AgrisellColors.headingGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AgrisellColors.limeSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AgrisellColors.limeGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.headset_mic_rounded,
                      color: AgrisellColors.forestGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Our customer support team is here to assist you. Typical response time is under 15 minutes.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AgrisellColors.headingGreen.withValues(alpha: 0.9),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Category Selector
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AgrisellColors.headingGreen,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SupportTicketCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    avatar: Icon(
                      cat.icon,
                      size: 16,
                      color: isSelected ? Colors.white : AgrisellColors.headingGreen,
                    ),
                    label: Text(cat.label),
                    selected: isSelected,
                    selectedColor: AgrisellColors.forestGreen,
                    backgroundColor: AgrisellColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AgrisellColors.headingGreen,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? AgrisellColors.forestGreen
                            : AgrisellColors.borderLine,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Priority Selector
              const Text(
                'Priority',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AgrisellColors.headingGreen,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: SupportTicketPriority.values.map((pri) {
                  final isSelected = _selectedPriority == pri;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(pri.label),
                      selected: isSelected,
                      selectedColor: pri.backgroundColor,
                      backgroundColor: AgrisellColors.surface,
                      labelStyle: TextStyle(
                        color: isSelected ? pri.textColor : AgrisellColors.mutedText,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected
                              ? pri.textColor.withValues(alpha: 0.5)
                              : AgrisellColors.borderLine,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedPriority = pri);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Subject Input
              const Text(
                'Subject',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AgrisellColors.headingGreen,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _subjectController,
                maxLength: 255,
                decoration: InputDecoration(
                  hintText: 'Brief summary of your inquiry...',
                  hintStyle: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AgrisellColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AgrisellColors.borderLine),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AgrisellColors.borderLine),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AgrisellColors.forestGreen,
                      width: 1.5,
                    ),
                  ),
                  counterText: '',
                ),
                validator: (val) {
                  final text = val?.trim() ?? '';
                  if (text.length < 2) {
                    return 'Subject must be at least 2 characters long.';
                  }
                  if (text.length > 255) {
                    return 'Subject cannot exceed 255 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Detailed Message Input
              const Text(
                'Message',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AgrisellColors.headingGreen,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _messageController,
                minLines: 4,
                maxLines: 8,
                maxLength: 4000,
                decoration: InputDecoration(
                  hintText: 'Provide details, context, or questions for our support team...',
                  hintStyle: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AgrisellColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AgrisellColors.borderLine),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AgrisellColors.borderLine),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AgrisellColors.forestGreen,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (val) {
                  final text = val?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Please describe your inquiry or issue.';
                  }
                  if (text.length > 4000) {
                    return 'Message cannot exceed 4000 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AgrisellColors.forestGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Submit Support Ticket',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
