/// BMJ design system — modal sheet.
///
/// One presentation for every sheet in the app (size picker, address picker,
/// order confirmation, filters). Radius 24, 24 px blur, hairline border and a
/// drag handle — matching the `vibrant_zest` mocks (BMJ_UX_REHAUL_PLAN.md §3).
///
/// Usage:
/// ```dart
/// final size = await BMJGlassSheet.show<String>(
///   context: context,
///   title: 'Choose a size',
///   child: const SizeList(),
/// );
/// ```
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// Glass modal sheet body. Prefer [BMJGlassSheet.show] over constructing this
/// directly so the route, barrier and height policy stay consistent.
class BMJGlassSheet extends StatelessWidget {
  /// Optional heading; rendered with a close button when [showClose] is true.
  final String? title;

  /// Sheet content.
  final Widget child;

  /// Optional sticky footer (a `BMJGlassButton`).
  final Widget? action;

  /// Drag handle above the title.
  final bool showHandle;

  /// Close affordance in the header row.
  final bool showClose;

  /// Content padding.
  final EdgeInsetsGeometry padding;

  /// Makes the body scroll on overflow instead of clipping.
  final bool scrollable;

  /// Optional controller when the caller needs to react to scrolling.
  final ScrollController? scrollController;

  const BMJGlassSheet({
    super.key,
    required this.child,
    this.title,
    this.action,
    this.showHandle = true,
    this.showClose = true,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.lg,
    ),
    this.scrollable = true,
    this.scrollController,
  });

  /// Opens a [BMJGlassSheet] in a transparent, scroll-controlled modal route.
  ///
  /// Returns whatever the route is popped with. [maxHeightFactor] caps the sheet
  /// at a fraction of the screen so tall content scrolls inside the glass.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String? title,
    Widget? action,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showHandle = true,
    bool showClose = true,
    double maxHeightFactor = 0.92,
    Color? barrierColor,
  }) {
    final palette = BMJPalette.of(context);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor ?? palette.onSurface.withValues(alpha: 0.45),
      builder: (sheetContext) {
        final insets = MediaQuery.viewInsetsOf(sheetContext);
        final size = MediaQuery.sizeOf(sheetContext);

        return Padding(
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: size.height * maxHeightFactor),
            child: BMJGlassSheet(
              title: title,
              action: action,
              showHandle: showHandle,
              showClose: showClose,
              child: builder(sheetContext),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final radius = BorderRadius.vertical(
      top: Radius.circular(AppRadius.sheet),
    );

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showHandle)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.onSurfaceVariant.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(BMJTokens.radiusPill),
                ),
              ),
            ),
          ),
        if (title != null || showClose)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              0,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.textTheme.titleLarge?.copyWith(
                        color: palette.onSurface,
                      ),
                    ),
                  ),
                ),
                if (showClose)
                  Semantics(
                    button: true,
                    label: 'Close',
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close_rounded),
                      color: palette.onSurfaceVariant,
                      tooltip: 'Close',
                      constraints: const BoxConstraints(
                        minWidth: BMJTokens.minTouchTarget,
                        minHeight: BMJTokens.minTouchTarget,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        Flexible(
          child: Padding(
            padding: padding,
            child: scrollable
                ? SingleChildScrollView(
                    controller: scrollController,
                    child: child,
                  )
                : child,
          ),
        ),
        if (action != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: action,
          ),
      ],
    );

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: BMJTokens.blurSheet,
          sigmaY: BMJTokens.blurSheet,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              color: palette.surfaceContainerHigh,
              borderRadius: radius,
              border: Border(
                top: BorderSide(
                  color: palette.glassBorder,
                  width: BMJTokens.hairline,
                ),
              ),
            ),
            child: SafeArea(top: false, child: body),
          ),
        ),
      ),
    );
  }
}
