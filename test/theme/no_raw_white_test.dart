/// Guard test: the migrated screens and shared widgets must not paint with a
/// raw `Colors.white`.
///
/// Raw white was the root of the light-theme bugs: a "white" panel/text is
/// invisible on the `#FFF8F1` surface and unreadable in dark mode. The
/// migration replaced it with two tokens:
/// - `BMJTokens.inkOnBrand` — white ink on a gradient or solid primary fill;
/// - `BMJPalette.surfaceContainer` — a white *surface*.
@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// Files in scope for the Stitch `vibrant_zest` migration.
///
/// Add a path here when a screen/widget is migrated; the test then keeps it
/// from drifting back to raw white.
const List<String> _scopedFiles = <String>[
  // Priority screens.
  'lib/views/screens/detail.dart',
  'lib/views/screens/home_tab.dart',
  'lib/views/screens/cart_screen.dart',
  'lib/views/screens/subscription_management_screen.dart',
  // Catalogue + subscription flows.
  'lib/views/screens/menu_tab.dart',
  'lib/views/screens/subscription/subscription_family_screen.dart',
  'lib/views/screens/subscription/subscription_plan_screen.dart',
  'lib/views/screens/subscription/subscription_schedule_screen.dart',
  'lib/views/screens/subscription/subscription_summary_screen.dart',
  // Shared legacy widgets.
  'lib/widgets/app_drawer.dart',
  'lib/widgets/hero_header.dart',
  'lib/widgets/subscription_card.dart',
  'lib/views/widgets/app_card.dart',
  'lib/views/widgets/cart_icon.dart',
  'lib/views/widgets/dashboard_components.dart',
  'lib/views/widgets/filter_options.dart',
  'lib/views/models/item_card_view.dart',
  'lib/views/models/detailed_juice_card.dart',
  'lib/views/widgets/size_selection_modal.dart',
  'lib/views/widgets/subscription_plan_card.dart',
  'lib/views/widgets/welcome_header.dart',
  'lib/views/widgets/my_bottles_widget.dart',
];

/// `Colors.white`, but not `AppColors.white`.
final RegExp _rawWhite = RegExp(r'(?<!App)Colors\.white\b');

void main() {
  test('migrated files never use raw Colors.white', () {
    final List<String> violations = <String>[];

    for (final String path in _scopedFiles) {
      final File file = File(path);
      expect(
        file.existsSync(),
        isTrue,
        reason: '$path does not exist — update _scopedFiles in this test.',
      );

      final List<String> lines = file.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final String line = lines[i];
        final String trimmed = line.trimLeft();
        // Documentation may mention the old API by name.
        if (trimmed.startsWith('//')) continue;
        if (_rawWhite.hasMatch(line)) {
          violations.add('$path:${i + 1}: ${line.trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Use BMJTokens.inkOnBrand for white ink on a brand surface, or '
          'BMJPalette.surfaceContainer for a white surface:\n'
          '${violations.join('\n')}',
    );
  });

  test('BMJTokens.inkOnBrand is pure white', () {
    expect(BMJTokens.inkOnBrand, const Color(0xFFFFFFFF));
  });
}
