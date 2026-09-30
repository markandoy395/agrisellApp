import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/utils/responsive.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.hintText,
    this.controller,
    this.showPasswordToggle = false,
    this.leadingIcon,
    this.leadingIconBadge = false,
    this.leadingIconDivider = true,
    this.trailingIcon,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.focusNode,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    super.key,
  });
  final String hintText;
  final TextEditingController? controller;
  final bool showPasswordToggle;
  final IconData? leadingIcon;
  final bool leadingIconBadge;
  final bool leadingIconDivider;
  final IconData? trailingIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  static const _fieldHeight = AuthInputStyle.height;
  static const _heightPerExtraTextPixel = 2.0;
  static const _floatingLabelKey = Key('auth-floating-label');
  bool _isHidden = true;
  bool _isFocused = false;
  bool _hasText = false;
  @override
  void initState() {
    super.initState();
    _hasText = widget.controller?.text.isNotEmpty ?? false;
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller?.removeListener(_handleControllerChanged);
    _hasText = widget.controller?.text.isNotEmpty ?? false;
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);
    final textScaler = MediaQuery.textScalerOf(context);
    final isPassword = widget.showPasswordToggle;
    final textSize = lerpDouble(12, 14, scale);
    final isFloating = _isFocused || _hasText;
    final fieldHeight =
        _fieldHeight +
        (textScaler.scale(textSize) - textSize).clamp(0.0, double.infinity) *
            _heightPerExtraTextPixel;
    const suffixIconConstraints = BoxConstraints(minWidth: 48, minHeight: 40);
    const border = AuthInputStyle.border;
    final errorBorder = border.copyWith(
      borderSide: const BorderSide(color: AgrisellColors.statusRedText),
    );
    return SizedBox(
      height: fieldHeight,
      child: Focus(
        onFocusChange: _handleFocusChanged,
        child: Stack(
          children: [
            Positioned.fill(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                obscureText: isPassword && _isHidden,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                autofillHints: widget.autofillHints,
                inputFormatters: widget.inputFormatters,
                readOnly: widget.readOnly,
                enabled: widget.enabled,
                onTap: widget.onTap,
                onChanged: _handleChanged,
                cursorColor: AgrisellColors.authGreen,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: isFloating ? null : widget.hintText,
                  hintStyle: TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: textSize,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: AuthInputStyle.fillColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 18,
                  ),
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border.copyWith(
                    borderSide: const BorderSide(
                      color: AgrisellColors.authGreen,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: errorBorder,
                  focusedErrorBorder: errorBorder,
                  disabledBorder: border,
                  prefixIcon: AuthInputStyle.iconBadge(
                    widget.leadingIcon ??
                        AuthInputStyle.iconFor(widget.hintText),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 52,
                    minHeight: 40,
                  ),
                  suffixIconConstraints:
                      isPassword || widget.trailingIcon != null
                      ? suffixIconConstraints
                      : null,
                  suffixIcon: isPassword
                      ? IconButton(
                          tooltip: _isHidden
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () =>
                              setState(() => _isHidden = !_isHidden),
                          constraints: suffixIconConstraints,
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          color: AgrisellColors.authGreen,
                          icon: Icon(
                            _isHidden
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        )
                      : widget.trailingIcon != null
                      ? Icon(
                          widget.trailingIcon,
                          color: AgrisellColors.mutedText,
                          size: 22,
                        )
                      : null,
                ),
                style: TextStyle(
                  color: AgrisellColors.brandBlack,
                  fontSize: textSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (isFloating)
              Positioned(
                left: 10,
                top: 0,
                child: IgnorePointer(
                  child: Container(
                    key: _floatingLabelKey,
                    color: AuthInputStyle.fillColor,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      widget.hintText,
                      style: AgrisellTheme.floatingInputLabelStyle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleChanged(String value) {
    final hasText = value.isNotEmpty;
    if (widget.controller == null && _hasText != hasText) {
      setState(() => _hasText = hasText);
    }
    widget.onChanged?.call(value);
  }

  void _handleControllerChanged() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (mounted && _hasText != hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleFocusChanged(bool hasFocus) {
    if (_isFocused != hasFocus) {
      setState(() => _isFocused = hasFocus);
    }
  }
}
