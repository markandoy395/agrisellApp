import 'package:agresell_app/features/shared/chat/presentation/styles/chat_reference_styles.dart';

abstract final class RiderMessageComposerStyles {
  static final inputDecoration = ChatReferenceStyles.input.copyWith(
    hintText: 'Write a delivery message',
  );
  static final iconButtonStyle = ChatReferenceStyles.sendButton;
}
