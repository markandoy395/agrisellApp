import 'package:flutter/material.dart'; import 'package:flutter/services.dart';
 import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/utils/responsive.dart'; 
class AuthTextField extends StatefulWidget { const AuthTextField({
    required this.hintText, this.controller,
    this.showPasswordToggle = false, this.keyboardType,
    this.textInputAction, this.autofillHints,
    this.inputFormatters, this.focusNode,
    this.readOnly = false, this.onTap,
    this.onChanged, super.key,
  }); 
  final String hintText; final TextEditingController? controller;
  final bool showPasswordToggle; final TextInputType? keyboardType;
  final TextInputAction? textInputAction; final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters; final FocusNode? focusNode;
  final bool readOnly; final VoidCallback? onTap;
  final ValueChanged<String>? onChanged; 
  @override State<AuthTextField> createState() => _AuthTextFieldState();
} 
class _AuthTextFieldState extends State<AuthTextField> { static const _fieldHeight = 56.0;
  static const _heightPerExtraTextPixel = 2.0; static const _floatingLabelKey = Key('auth-floating-label');
 bool _isHidden = true;
  bool _isFocused = false; bool _hasText = false;
 @override
  void initState() { super.initState();
    widget.controller?.addListener(_handleControllerChanged); }
 @override
  void didUpdateWidget(covariant AuthTextField oldWidget) { super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return; oldWidget.controller?.removeListener(_handleControllerChanged);
    widget.controller?.addListener(_handleControllerChanged); }
 @override
  void dispose() { widget.controller?.removeListener(_handleControllerChanged);
    super.dispose(); }
 @override
  Widget build(BuildContext context) { final scale = authScale(MediaQuery.sizeOf(context).width);
    final textScaler = MediaQuery.textScalerOf(context); final isPassword = widget.showPasswordToggle;
    final textSize = lerpDouble(12, 14, scale); final isFloating =
        _isFocused || (widget.controller?.text.isNotEmpty ?? _hasText); final fieldHeight =
        _fieldHeight + (textScaler.scale(textSize) - textSize).clamp(0.0, double.infinity) *
            _heightPerExtraTextPixel; final suffixIconConstraints = BoxConstraints.tightFor(
      width: isPassword ? 48 : 0, height: fieldHeight,
    ); final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AgrisellColors.borderLine),
    ); final errorBorder = border.copyWith(
      borderSide: const BorderSide(color: AgrisellColors.statusRedText), );
 return SizedBox(
      height: fieldHeight, child: Focus(
        onFocusChange: _handleFocusChanged, child: Stack(
          children: [ Positioned.fill(
              child: TextField( controller: widget.controller,
                focusNode: widget.focusNode, obscureText: isPassword && _isHidden,
                keyboardType: widget.keyboardType, textInputAction: widget.textInputAction,
                autofillHints: widget.autofillHints, inputFormatters: widget.inputFormatters,
                readOnly: widget.readOnly, onTap: widget.onTap,
                onChanged: _handleChanged, cursorColor: AgrisellColors.authGreen,
                textAlignVertical: TextAlignVertical.center, decoration: InputDecoration(
                  hintText: isFloating ? null : widget.hintText, hintStyle: TextStyle(
                    color: AgrisellColors.mutedText, fontSize: textSize,
                  ), isDense: true,
                  filled: true, fillColor: AgrisellColors.fieldFill,
                  contentPadding: const EdgeInsets.symmetric( horizontal: 14,
                    vertical: 10, ),
                  border: border, enabledBorder: border,
                  focusedBorder: border.copyWith( borderSide: const BorderSide(
                      color: AgrisellColors.authGreen, width: 1.5,
                    ), ),
                  errorBorder: errorBorder, focusedErrorBorder: errorBorder,
                  disabledBorder: border, suffixIconConstraints: suffixIconConstraints,
                  suffixIcon: isPassword ? IconButton(
                          tooltip: _isHidden ? 'Show password'
                              : 'Hide password', onPressed: () =>
                              setState(() => _isHidden = !_isHidden), constraints: suffixIconConstraints,
                          padding: EdgeInsets.zero, iconSize: 20,
                          color: AgrisellColors.authGreen, icon: Icon(
                            _isHidden ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined, ),
                        ) : const SizedBox.shrink(),
                ), style: TextStyle(
                  color: AgrisellColors.brandBlack, fontSize: textSize,
                  fontWeight: FontWeight.w400, ),
              ), ),
            if (isFloating) Positioned(
                left: 10, top: 0,
                child: IgnorePointer( child: Container(
                    key: _floatingLabelKey, color: AgrisellColors.fieldFill,
                    padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(
                      widget.hintText, style: const TextStyle(
                        color: AgrisellColors.authGreen, fontSize: 12,
                        fontWeight: FontWeight.w600, height: 1.2,
                      ), ),
                  ), ),
              ), ],
        ), ),
    ); }
 void _handleChanged(String value) {
    final hasText = value.isNotEmpty; if (widget.controller == null && _hasText != hasText) {
      setState(() => _hasText = hasText); }
    widget.onChanged?.call(value); }
 void _handleControllerChanged() {
    if (mounted) setState(() {}); }
 void _handleFocusChanged(bool hasFocus) {
    if (_isFocused != hasFocus) { setState(() => _isFocused = hasFocus);
    } }
}
