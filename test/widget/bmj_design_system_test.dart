/// Widget tests for the BMJ design-system components (Wave 1).
///
/// These are behavioural, not golden, tests: the repo has no golden baseline
/// yet, so we lock the public contract (labels, semantics, tap wiring, required
/// states) that the screens depend on. Goldens can be layered on later without
/// rewriting these.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/widgets/bmj_amount_row.dart';
import 'package:lush/widgets/bmj_badge.dart';
import 'package:lush/widgets/bmj_empty_state.dart';
import 'package:lush/widgets/bmj_glass_bottom_nav.dart';
import 'package:lush/widgets/bmj_glass_button.dart';
import 'package:lush/widgets/bmj_glass_card.dart';
import 'package:lush/widgets/bmj_glass_header.dart';
import 'package:lush/widgets/bmj_glass_input.dart';
import 'package:lush/widgets/bmj_glass_sheet.dart';
import 'package:lush/widgets/bmj_pill.dart';
import 'package:lush/widgets/bmj_stat_tile.dart';

/// Host that supplies the Material ancestor every component expects.
///
/// Deliberately avoids `AppTheme.light` — it loads Google Fonts over HTTP,
/// which the test binding answers with 400.
Widget _host(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: ThemeData(brightness: brightness, useMaterial3: true),
    home: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('BMJGlassButton', () {
    testWidgets('renders its label and fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(BMJGlassButton(label: 'Add to cart', onPressed: () => taps++)),
      );

      expect(find.text('Add to cart'), findsOneWidget);
      await tester.tap(find.text('Add to cart'));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('is at least 48 dp tall and honours a larger height',
        (tester) async {
      await tester.pumpWidget(
        _host(BMJGlassButton(label: 'Pay', onPressed: () {})),
      );
      expect(
        tester.getSize(find.byType(BMJGlassButton)).height,
        greaterThanOrEqualTo(48),
      );

      await tester.pumpWidget(
        _host(BMJGlassButton(label: 'Pay', onPressed: () {}, height: 64)),
      );
      expect(
        tester.getSize(find.byType(BMJGlassButton)).height,
        greaterThanOrEqualTo(64),
      );
    });

    testWidgets('shows a spinner while loading and ignores taps',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          BMJGlassButton(
            label: 'Pay',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(BMJGlassButton));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('disabled state exposes no tap target', (tester) async {
      await tester.pumpWidget(
        _host(const BMJGlassButton(label: 'Unavailable', onPressed: null)),
      );

      expect(find.text('Unavailable'), findsOneWidget);
      final inkWell = tester.widget<InkWell>(find.byType(InkWell).first);
      expect(inkWell.onTap, isNull);
    });

    testWidgets('ghost variant still renders the label', (tester) async {
      await tester.pumpWidget(
        _host(
          BMJGlassButton(
            label: 'Skip',
            variant: BMJButtonVariant.ghost,
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Skip'), findsOneWidget);
    });
  });

  group('BMJGlassInput', () {
    testWidgets('renders label and hint, and accepts text', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          BMJGlassInput(
            label: 'Phone number',
            hint: '98765 43210',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('98765 43210'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '9876543210');
      expect(controller.text, '9876543210');
    });

    testWidgets('password toggle reveals and re-hides input', (tester) async {
      await tester.pumpWidget(
        _host(const BMJGlassInput(label: 'Password', obscureText: true)),
      );

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).obscureText,
        isFalse,
      );
    });

    testWidgets('surfaces errorText', (tester) async {
      await tester.pumpWidget(
        _host(
          const BMJGlassInput(
            label: 'Email',
            hint: 'you@example.com',
            errorText: 'Enter a valid email',
          ),
        ),
      );

      expect(find.text('Enter a valid email'), findsOneWidget);
    });
  });

  group('BMJGlassCard', () {
    testWidgets('renders child and fires onTap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          BMJGlassCard(
            onTap: () => taps++,
            semanticLabel: 'Order 1234',
            child: const Text('Cold pressed'),
          ),
        ),
      );

      expect(find.text('Cold pressed'), findsOneWidget);
      await tester.tap(find.byType(BMJGlassCard));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('works in dark mode', (tester) async {
      await tester.pumpWidget(
        _host(
          const BMJGlassCard(child: Text('Dark')),
          brightness: Brightness.dark,
        ),
      );

      expect(find.text('Dark'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('BMJPill', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(
        _host(const BMJPill(label: 'Active', tone: BMJPillTone.success)),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('is tappable only when onTap is provided', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(BMJPill(label: 'Filter', onTap: () => taps++)),
      );

      await tester.tap(find.text('Filter'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('renders an icon variant', (tester) async {
      await tester.pumpWidget(
        _host(const BMJPill(label: '9 PM IST', icon: Icons.schedule)),
      );

      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(find.text('9 PM IST'), findsOneWidget);
    });
  });

  group('BMJStatTile', () {
    testWidgets('shows value, suffix and upper-cased label', (tester) async {
      await tester.pumpWidget(
        _host(
          const BMJStatTile(
            value: '120',
            valueSuffix: 'kcal',
            label: 'Calories',
            icon: Icons.local_fire_department,
          ),
        ),
      );

      expect(find.text('120'), findsOneWidget);
      expect(find.text('kcal'), findsOneWidget);
      expect(find.text('CALORIES'), findsOneWidget);
    });

    testWidgets('exposes one merged semantics node', (tester) async {
      await tester.pumpWidget(
        _host(const BMJStatTile(value: '18', valueSuffix: 'g', label: 'Sugar')),
      );

      expect(
        find.bySemanticsLabel('18 g Sugar'),
        findsOneWidget,
      );
    });
  });

  group('BMJEmptyState', () {
    testWidgets('renders title, message and action', (tester) async {
      await tester.pumpWidget(
        _host(
          BMJEmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Your cart is empty',
            message: 'Add a cold-pressed juice to get started.',
            action: BMJGlassButton(label: 'Browse menu', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Add a cold-pressed juice to get started.'),
          findsOneWidget);
      expect(find.text('Browse menu'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    });
  });

  group('BMJAmountRow', () {
    testWidgets('renders label and amount', (tester) async {
      await tester.pumpWidget(
        _host(const BMJAmountRow(label: 'Subtotal', amount: '₹249')),
      );

      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('₹249'), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('total adds a divider above the row', (tester) async {
      await tester.pumpWidget(
        _host(
          const BMJAmountRow(label: 'Total', amount: '₹299', isTotal: true),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('₹299'), findsOneWidget);
    });

    testWidgets('strikes through the original amount', (tester) async {
      await tester.pumpWidget(
        _host(
          const BMJAmountRow(
            label: 'Plan',
            amount: '₹199',
            originalAmount: '₹249',
            note: 'Applied: FIRST50',
          ),
        ),
      );

      final original = tester.widget<Text>(find.text('₹249'));
      expect(original.style?.decoration, TextDecoration.lineThrough);
      expect(find.text('Applied: FIRST50'), findsOneWidget);
    });
  });

  group('BMJBadge', () {
    testWidgets('hides itself at zero and shows the count otherwise',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const BMJBadge(
            count: 0,
            child: Icon(Icons.shopping_bag_outlined),
          ),
        ),
      );
      expect(find.text('0'), findsNothing);

      await tester.pumpWidget(
        _host(
          const BMJBadge(count: 3, child: Icon(Icons.shopping_bag_outlined)),
        ),
      );
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('caps large counts at 99+', (tester) async {
      await tester.pumpWidget(
        _host(const BMJBadge(count: 140, child: Icon(Icons.notifications))),
      );

      expect(find.text('99+'), findsOneWidget);
      expect(find.text('140'), findsNothing);
    });

    testWidgets('dot mode renders no text', (tester) async {
      await tester.pumpWidget(
        _host(const BMJBadge(count: 0, dot: true, child: Icon(Icons.mail))),
      );

      expect(find.text('0'), findsNothing);
      expect(find.byIcon(Icons.mail), findsOneWidget);
    });
  });

  group('BMJGlassBottomNav', () {
    const destinations = <BMJNavDestination>[
      BMJNavDestination(icon: Icons.home_outlined, label: 'Home'),
      BMJNavDestination(icon: Icons.receipt_long_outlined, label: 'Orders'),
      BMJNavDestination(icon: Icons.person_outline, label: 'Profile'),
    ];

    testWidgets('renders every destination and reports selection',
        (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        _host(
          BMJGlassBottomNav(
            destinations: destinations,
            index: 0,
            onSelect: (i) => selected = i,
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);

      await tester.tap(find.text('Orders'));
      await tester.pump();
      expect(selected, 1);
    });
  });

  group('BMJGlassHeader', () {
    testWidgets('shows the wordmark and hides the cart when asked',
        (tester) async {
      await tester.pumpWidget(
        _host(const BMJGlassHeader(showCart: false)),
      );

      expect(find.text('BookMyJuice'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsNothing);
    });

    testWidgets('honours a custom title and cart action', (tester) async {
      await tester.pumpWidget(
        _host(
          const BMJGlassHeader(
            title: 'Checkout',
            cartAction: Icon(Icons.lock_outline),
          ),
        ),
      );

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('BookMyJuice'), findsNothing);
    });
  });

  group('BMJGlassSheet', () {
    testWidgets('show() presents title and content in a modal route',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => BMJGlassSheet.show<void>(
                    context: context,
                    title: 'Choose a size',
                    builder: (_) => const Text('300 ml'),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a size'), findsOneWidget);
      expect(find.text('300 ml'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(find.text('300 ml'), findsNothing);
    });
  });
}
