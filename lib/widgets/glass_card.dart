/// Glassmorphism Card Widget
///
/// Reusable glass card with backdrop blur, gradient surface, and optional glow.
/// Adapts to light/dark theme automatically via [ThemeCubit].
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// Glassmorphism card with configurable blur, opacity, border, and glow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final double blur;
  final double opacity;
  final double borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool hasGlow;
  final Color? glowColor;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.blur = 10.0,
    this.opacity = 0.06,
    this.borderRadius = AppRadius.xl,
    this.borderWidth,
    this.borderColor,
    this.backgroundColor,
    this.hasGlow = false,
    this.glowColor,
    this.boxShadow,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final radius = BorderRadius.circular(borderRadius);
    final radiusValue = borderRadius;
    final fill = backgroundColor ?? palette.glassFill;
    final stroke = borderColor ?? palette.glassBorder;

    final shadows = boxShadow ??
        (hasGlow
            ? <BoxShadow>[
                BoxShadow(
                  color: (glowColor ?? palette.primary).withValues(alpha: 0.22),
                  blurRadius: BMJTokens.glowBlur,
                  spreadRadius: BMJTokens.glowSpread,
                ),
              ]
            : null);

    Widget card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height,
          width: width,
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: gradient != null ? null : fill,
            borderRadius: radius,
            border: Border.all(
              color: stroke,
              width: borderWidth ?? BMJTokens.hairline,
            ),
            gradient: gradient,
          ),
          child: child,
        ),
      ),
    );

    if (shadows != null && shadows.isNotEmpty) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radiusValue),
          boxShadow: shadows,
        ),
        child: card,
      );
    }

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }
    return card;
  }
}

/// Glassmorphism chip/tag widget.
class GlassChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final double borderRadius;
  final Color? selectedColor;
  final double? fontSize;

  const GlassChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.borderRadius = AppRadius.lg,
    this.selectedColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final accent = selectedColor ?? palette.primaryEmphasis;

    final bg = isSelected ? accent.withValues(alpha: 0.14) : palette.glassFill;
    final border =
        isSelected ? accent.withValues(alpha: 0.45) : palette.glassBorder;
    final textColor = isSelected ? accent : palette.onSurfaceVariant;

    return Semantics(
      button: onTap != null,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: BMJTokens.blurGlass * 0.5,
              sigmaY: BMJTokens.blurGlass * 0.5,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: border,
                  width: BMJTokens.hairline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, size: 16, color: textColor),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.textTheme.labelLarge?.copyWith(
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glassmorphism segment toggle (One-Time / Subscribe).
class GlassSegmentToggle extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onSegmentChanged;

  const GlassSegmentToggle({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSegmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: BMJTokens.blurGlass,
          sigmaY: BMJTokens.blurGlass,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: palette.glassFill,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: palette.glassBorder,
              width: BMJTokens.hairline,
            ),
          ),
          child: Row(
            children: List<Widget>.generate(segments.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: segments[index],
                  child: GestureDetector(
                    onTap: () => onSegmentChanged(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: BMJTokens.motionFast,
                      curve: BMJTokens.motionCurve,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? palette.primary.withValues(alpha: 0.16)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected
                              ? palette.primary.withValues(alpha: 0.45)
                              : Colors.transparent,
                          width: BMJTokens.hairline,
                        ),
                      ),
                      child: Text(
                        segments[index],
                        textAlign: TextAlign.center,
                        style: AppTextStyles.textTheme.labelLarge?.copyWith(
                          color: isSelected
                              ? palette.primaryEmphasis
                              : palette.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
