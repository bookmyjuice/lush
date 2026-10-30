/// BMJ design system — text input.
///
/// The Stitch field (BMJ_UX_REHAUL_PLAN.md §3): 8 px radius, label above the
/// field, 1 px hairline that turns 2 px orange on focus, 48 dp minimum height,
/// and a built-in obscure toggle so no screen hand-rolls one.
///
/// It keeps the contract the app already validates against — `validator`,
/// `controller`, `onChanged`, `keyboardType`, `inputFormatters` — so replacing
/// an `AppTextField` is a rename plus the new optional extras.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// Stitch text field with label, hint, error and password toggle.
class BMJGlassInput extends StatefulWidget {
  /// Label rendered above the field.
  final String? label;

  /// Placeholder inside the field.
  final String? hint;

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  /// Renders dots and shows the eye toggle when [showObscureToggle] is true.
  final bool obscureText;

  /// Whether the eye toggle is offered for an obscured field.
  final bool showObscureToggle;

  final IconData? prefixIcon;
  final Widget? suffix;
  final String? errorText;
  final String? helperText;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;

  /// Called when the eye toggle flips visibility.
  final ValueChanged<bool>? onObscureChanged;

  final bool enabled;
  final bool readOnly;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final AutovalidateMode? autovalidateMode;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;

  const BMJGlassInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.obscureText = false,
    this.showObscureToggle = true,
    this.prefixIcon,
    this.suffix,
    this.errorText,
    this.helperText,
    this.onChanged,
    this.onFieldSubmitted,
    this.onObscureChanged,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.autovalidateMode,
    this.autofillHints,
    this.focusNode,
  });

  @override
  State<BMJGlassInput> createState() => _BMJGlassInputState();
}

class _BMJGlassInputState extends State<BMJGlassInput> {
  late bool _obscured = widget.obscureText;

  @override
  void didUpdateWidget(covariant BMJGlassInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  void _toggleObscure() {
    setState(() => _obscured = !_obscured);
    widget.onObscureChanged?.call(_obscured);
  }

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final textStyle = AppTextStyles.textTheme.bodyLarge?.copyWith(
      color: palette.onSurface,
    );

    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: color),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(
            widget.label!,
            style: AppTextStyles.textTheme.labelLarge?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: BMJTokens.minTouchTarget),
          child: TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            obscureText: _obscured,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLength: widget.maxLength,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            autovalidateMode: widget.autovalidateMode,
            autofillHints: widget.autofillHints,
            focusNode: widget.focusNode,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
            style: textStyle,
            cursorColor: palette.primary,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: textStyle?.copyWith(
                color: palette.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              errorText: widget.errorText,
              helperText: widget.helperText,
              helperMaxLines: 2,
              errorMaxLines: 2,
              counterText: '',
              filled: true,
              fillColor: palette.surfaceContainer,
              prefixIcon: widget.prefixIcon == null
                  ? null
                  : Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: palette.onSurfaceVariant,
                    ),
              suffixIcon: widget.obscureText && widget.showObscureToggle
                  ? IconButton(
                      onPressed: _toggleObscure,
                      tooltip: _obscured ? 'Show password' : 'Hide password',
                      icon: Icon(
                        _obscured
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: palette.onSurfaceVariant,
                      ),
                    )
                  : widget.suffix,
              border: border(palette.outlineVariant),
              enabledBorder: border(
                widget.errorText != null
                    ? palette.error
                    : palette.outlineVariant,
              ),
              focusedBorder: border(palette.primary).copyWith(
                borderSide: BorderSide(color: palette.primary, width: 2),
              ),
              errorBorder: border(palette.error),
              focusedErrorBorder: border(palette.error).copyWith(
                borderSide: BorderSide(color: palette.error, width: 2),
              ),
              disabledBorder: border(
                palette.outlineVariant.withValues(alpha: 0.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
