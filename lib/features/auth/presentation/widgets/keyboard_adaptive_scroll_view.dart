import 'package:flutter/material.dart';

class KeyboardAdaptiveScrollView extends StatefulWidget {
  const KeyboardAdaptiveScrollView({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.fillRemaining = false,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool fillRemaining;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  @override
  State<KeyboardAdaptiveScrollView> createState() =>
      _KeyboardAdaptiveScrollViewState();
}

class _KeyboardAdaptiveScrollViewState
    extends State<KeyboardAdaptiveScrollView> {
  final _controller = ScrollController();
  bool? _keyboardWasVisible;
  var _overflowedBeforeKeyboard = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final wasVisible = _keyboardWasVisible;

    if (wasVisible == false && keyboardVisible) {
      _overflowedBeforeKeyboard =
          _controller.hasClients && _controller.position.maxScrollExtent > 0;
    } else if (wasVisible == true &&
        !keyboardVisible &&
        !_overflowedBeforeKeyboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) _controller.jumpTo(0);
      });
    }

    _keyboardWasVisible = keyboardVisible;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.fillRemaining) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final resolvedPadding = widget.padding.resolve(
            Directionality.of(context),
          );
          final minHeight = (constraints.maxHeight - resolvedPadding.vertical)
              .clamp(0.0, double.infinity)
              .toDouble();

          return SingleChildScrollView(
            controller: _controller,
            padding: widget.padding,
            keyboardDismissBehavior: widget.keyboardDismissBehavior,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: widget.child,
            ),
          );
        },
      );
    }

    return CustomScrollView(
      controller: _controller,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      slivers: [
        SliverPadding(
          padding: widget.padding,
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
