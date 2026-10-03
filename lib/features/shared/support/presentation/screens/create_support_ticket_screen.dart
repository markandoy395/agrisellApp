import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_tickets_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_ticket_detail_screen.dart';

import '../styles/create_support_ticket_styles.dart';
import '../widgets/create_support_ticket_category_picker.dart';
import '../widgets/create_support_ticket_form_fields.dart';
import '../widgets/create_support_ticket_info_card.dart';
import '../widgets/create_support_ticket_priority_picker.dart';
import '../widgets/create_support_ticket_submit_button.dart';

/// Screen allowing buyers, farmers, and riders to create and submit a support ticket.
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
    _subjectController = TextEditingController(
      text: widget.initialSubject ?? '',
    );
    _messageController = TextEditingController(
      text: widget.initialMessage ?? '',
    );
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
        CreateSupportTicketStyles.successSnackBar(created.ticketNumber),
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
        CreateSupportTicketStyles.errorSnackBar(
          _controller.errorMessage ?? 'Failed to submit support ticket.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CreateSupportTicketStyles.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Open Support Ticket',
          style: CreateSupportTicketStyles.appBarTitle,
        ),
        backgroundColor: CreateSupportTicketStyles.surfaceColor,
        foregroundColor: CreateSupportTicketStyles.appBarTitleColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: CreateSupportTicketStyles.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CreateSupportTicketInfoCard(),
              const SizedBox(height: CreateSupportTicketStyles.sectionSpacing),
              CreateSupportTicketCategoryPicker(
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) {
                  setState(() => _selectedCategory = cat);
                },
              ),
              const SizedBox(height: CreateSupportTicketStyles.sectionSpacing),
              CreateSupportTicketPriorityPicker(
                selectedPriority: _selectedPriority,
                onPrioritySelected: (pri) {
                  setState(() => _selectedPriority = pri);
                },
              ),
              const SizedBox(height: CreateSupportTicketStyles.sectionSpacing),
              CreateSupportTicketFormFields(
                subjectController: _subjectController,
                messageController: _messageController,
              ),
              const SizedBox(height: CreateSupportTicketStyles.submitSpacing),
              CreateSupportTicketSubmitButton(
                isSubmitting: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
