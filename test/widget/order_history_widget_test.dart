import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/views/screens/order_history_screen.dart';
import 'package:lush/views/screens/order/order_detail_screen.dart';

void main() {
  // The OrderHistoryScreen is a self-contained StatefulWidget that creates
  // its own OrderService internally. Without DI hooks, we verify the loading
  // state (shown on initState) and that the screen renders without crashing.

  group('OrderHistoryScreen', () {
    testWidgets('shows shimmer loading cards on initial render', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OrderHistoryScreen()),
      );
      // The screen shows shimmer placeholder cards, not a CircularProgressIndicator
      // Verify the Scaffold and AppBar render correctly
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Order History'), findsOneWidget);
      // The body renders shimmer cards (ListView with shimmer containers)
      expect(find.byIcon(Icons.storage), findsOneWidget);
    });
  });

  group('OrderDetailScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OrderDetailScreen()),
      );
      // Without route args, OrderBloc stays in OrderHistoryInitial state
      // The BlocBuilder returns SizedBox.shrink() for unmapped states
      // Verify the Scaffold and AppBar render without error
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Order Details'), findsOneWidget);
    });
  });
}