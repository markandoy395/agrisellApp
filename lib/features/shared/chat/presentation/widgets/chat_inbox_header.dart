import 'package:agresell_app/features/shared/chat/presentation/styles/chat_inbox_header_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

class ChatInboxHeader extends StatelessWidget {
  const ChatInboxHeader({
    required this.title,
    required this.searchHint,
    required this.controller,
    required this.onQueryChanged,
    super.key,
  });

  final String title;
  final String searchHint;
  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 14.0 : 18.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topInset + 14,
        horizontalPadding,
        14,
      ),
      decoration: ChatInboxHeaderStyles.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: SharedPresentationStyles.headingTitleExtraBold),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: onQueryChanged,
            textInputAction: TextInputAction.search,
            style: ChatInboxHeaderStyles.textStyle,
            decoration: ChatInboxHeaderStyles.inputDecoration(
              searchHint,
              controller,
              onQueryChanged,
            ),
          ),
        ],
      ),
    );
  }
}
