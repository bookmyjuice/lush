/// BMJ design system — floating glass navigation bar.
///
/// A pill of frosted glass that floats [BMJTokens.spaceSm] above the bottom
/// safe area (BMJ_UX_REHAUL_PLAN.md §3). The active destination gets an orange
/// pill plus a soft aura; icons stay 22 px and labels 11 px so five
/// destinations still fit at 360 dp.
///
/// Semantics are preserved for the existing widget tests: each destination
/// carries `selected`, `button` and a label that defaults to
/// `'<label>_tab'` (e.g. `home_tab`), exactly like the current
/// `BottomNavigationBar`.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// One destination in [BMJGlassBottomNav].
class BMJNavDestination {
  /// Outlined icon when inactive.
  final IconData icon;

  /// Filled icon when active.
  final IconData selectedIcon;

  /// Visible label.
  final String label;

  /// Semantics label; defaults to `'<label>_tab'`.
  final String? semanticLabel;

  const BMJNavDestination({
    required this.icon,
    required this.label,
    IconData? selectedIcon,
    this.semanticLabel,
  }) : selectedIcon = selectedIcon ?? icon;

  String get a11yLabel =>
      semanticLabel ?? '${label.toLowerCase().replaceAll(' ', '_')}_tab';
}

/// Floating glass bottom navigation.
class BMJGlassBottomNav extends StatelessWidget {
  /// Destinations, in order.
  final List<BMJNavDestination> destinations;

  /// Currently selected index.
  final int index;

  /// Called with the tapped index.
  final ValueChanged<int> onSelect;

  /// Extra bottom margin (the shell normally lets this widget own the safe
  /// area).
  final double bottomMargin;

  const BMJGlassBottomNav({
    super.key,
    required this.destinations,
    required this.index,
    required this.onSelect,
    this.bottomMargin = BMJTokens.spaceMd,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final radius = BorderRadius.circular(AppRadius.pill);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          BMJTokens.pageMargin,
          0,
          BMJTokens.pageMargin,
          bottomMargin,
        ),
        child: Semantics(
          container: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: palette.primary.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: BMJTokens.blurSheet,
                  sigmaY: BMJTokens.blurSheet,
                ),
                child: Material(
                  color: palette.glassFillStrong,
                  shape: RoundedRectangleBorder(
                    borderRadius: radius,
                    side: BorderSide(
                      color: palette.glassBorder,
                      width: BMJTokens.hairline,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(BMJTokens.spaceXs),
                    child: Row(
                      children: <Widget>[
                        for (var i = 0; i < destinations.length; i++)
                          Expanded(
                            child: _NavItem(
                              destination: destinations[i],
                              selected: i == index,
                              onTap: () => onSelect(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final BMJNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final color = selected ? palette.onPrimary : palette.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.a11yLabel,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: SizedBox(
            height: BMJTokens.minTouchTarget + 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedContainer(
                  duration: BMJTokens.motionFast,
                  curve: BMJTokens.motionCurve,
                  padding: const EdgeInsets.symmetric(
                    horizontal: BMJTokens.spaceMd,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    // The reference fills the active item with solid accent and
                    // flips its content to light ink; a 16 % tint read as a
                    // hover state, not as "you are here".
                    color: selected ? palette.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: selected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: palette.primary.withValues(alpha: 0.50),
                              blurRadius: 22,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    size: 24,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
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
