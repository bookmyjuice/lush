/// Glassmorphism Card Widget
///
/// Reusable glass card with backdrop blur, gradient surface, and optional glow.
/// Adapts to light/dark theme automatically via [ThemeCubit].
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/theme_cubit.dart';

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
    final isDark = context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;

    final effectiveBg = backgroundColor ??
        (isDark ? AppColors.glassSurface : AppColors.glassSurfaceLight);

    final effectiveBorder = borderColor ??
        (isDark ? AppColors.glassBorder : AppColors.glassBorderLight);

    final effectiveShadow = boxShadow ??
        (hasGlow
            ? [
                BoxShadow(
                  color: glowColor ?? AppColors.glassGlow,
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ]
            : []);

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: isDark
            ? ImageFilter.blur(sigmaX: blur, sigmaY: blur)
            : ImageFilter.blur(sigmaX: blur * 0.5, sigmaY: blur * 0.5),
        child: Container(
          height: height,
          width: width,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: gradient != null ? Colors.transparent : effectiveBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: effectiveBorder,
              width: borderWidth ?? 0.5,
            ),
            gradient: gradient,
            boxShadow: effectiveShadow.isNotEmpty ? effectiveShadow : null,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
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
    final isDark = context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;

    final bg = isSelected
        ? (selectedColor ?? AppColors.glassAccent).withValues(alpha: 0.2)
        : (isDark ? AppColors.glassSurface : AppColors.glassSurfaceLight);

    final border = isSelected
        ? (selectedColor ?? AppColors.glassAccent).withValues(alpha: 0.5)
        : (isDark ? AppColors.glassBorderSubtle : AppColors.glassBorderLight);

    final textColor = isSelected
        ? (selectedColor ?? AppColors.glassAccent)
        : (isDark ? AppColors.glassTextDim : AppColors.lightTextSecondary);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: border, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: textColor),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: fontSize ?? 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ],
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
    final isDark = context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.glassSurface.withValues(alpha: 0.8)
                : AppColors.glassSurfaceLight.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? AppColors.glassBorderSubtle : AppColors.glassBorderLight,
            ),
          ),
          child: Row(
            children: List.generate(segments.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSegmentChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.glassAccent.withValues(alpha: 0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      segments[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.glassAccent
                            : (isDark
                                ? AppColors.glassTextDim
                                : AppColors.lightTextSecondary),
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