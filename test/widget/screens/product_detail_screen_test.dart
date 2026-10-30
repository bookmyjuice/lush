/// Widget tests for the product detail page (Stitch `juice_detail_selection`).
///
/// Locks the approved flow — product tile -> PDP -> existing size sheet ->
/// cart -> checkout — and the catalog-price contract behind it:
/// - every size pill carries a real `ItemPrice` id and price;
/// - picking a pill updates the primary CTA price;
/// - "Select options" (hero) and "Choose quantity" (size card) open the
///   shared `SizeSelectionSheet` used by Menu and Home quick-add;
/// - the legacy `Product` entry point stays renderable.
library;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/CartRepository/cart_repository.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/ProductCatalogBloc/product_catalog_bloc.dart';
import 'package:lush/utils/analytics_service.dart';
import 'package:lush/utils/price_utils.dart';
import 'package:lush/views/models/cart_item.dart';
import 'package:lush/views/models/item.dart';
import 'package:lush/views/models/model.dart';
import 'package:lush/views/screens/detail.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockCartRepository extends Mock implements CartRepository {}

List<ItemPrice> _prices() => <ItemPrice>[
      ItemPrice(id: 'pineapple-200ml', name: '200ml', price: 149),
      ItemPrice(id: 'pineapple-300ml', name: '300ml', price: 199),
      ItemPrice(id: 'pineapple-500ml', name: '500ml', price: 292),
    ];

CatalogItem _catalogItem() => CatalogItem(
      item: Item(
        id: 'pineapple-delight',
        name: 'Pineapple Delight',
        description: 'Cold-pressed pineapple with a squeeze of lime.',
        imagePath: 'assets/pineapple.png',
        kacl: 118,
        rating: 4.8,
        meals: <String>['Pineapple', 'Lime', 'Mint'],
        servingSize: '300ml',
        itemPrices: _prices(),
      ),
      category: 'Delight',
      prices: _prices(),
    );

Widget _host(Widget child, CartBloc cartBloc) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => ToastificationWrapper(
      child: MaterialApp(
        theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
        home: BlocProvider<CartBloc>.value(value: cartBloc, child: child),
      ),
    ),
  );
}

/// Tall phone viewport so the whole PDP (hero + size sheet + CTAs) is laid out.
Future<void> _pumpPdp(
  WidgetTester tester,
  Widget page,
  CartBloc cartBloc,
) async {
  tester.view.physicalSize = const Size(780, 3200);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_host(page, cartBloc));
  await tester.pumpAndSettle();
}

void main() {
  late MockCartRepository cartRepository;
  late CartBloc cartBloc;
  late MockFirebaseAnalytics analytics;

  setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

  setUp(() {
    cartRepository = MockCartRepository();
    when(() => cartRepository.getCartItems())
        .thenAnswer((_) async => <CartItem>[]);
    when(() => cartRepository.saveCartItems(any())).thenAnswer((_) async {});
    cartBloc = CartBloc(cartRepository);

    // Firebase Analytics has no platform channel in the test VM.
    analytics = MockFirebaseAnalytics();
    AnalyticsService.setAnalyticsForTesting(analytics);
    when(() => analytics.logViewItem(items: any(named: 'items')))
        .thenAnswer((_) async {});
    when(
      () => analytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    AnalyticsService.resetAnalyticsForTesting();
    await cartBloc.close();
  });

  testWidgets('renders name, price, every catalog size and both CTAs',
      (WidgetTester tester) async {
    await _pumpPdp(tester, DetailPage.catalog(_catalogItem()), cartBloc);

    expect(find.text('Pineapple Delight'), findsOneWidget);
    // Title block and the one-time row both quote the same real catalog price.
    expect(find.text(formatRupees(149)), findsWidgets);
    for (final ItemPrice price in _prices()) {
      expect(
        find.text('${price.name} · ${formatRupees(price.price)}'),
        findsOneWidget,
        reason: 'size pill for ${price.id} must show its catalog price',
      );
    }
    expect(find.text('Select a size'), findsOneWidget);
    expect(find.text('Key ingredients'), findsOneWidget);
    expect(find.text('Add to cart · ${formatRupees(149)}'), findsOneWidget);
    expect(find.text('Choose quantity'), findsOneWidget);
  });

  testWidgets('picking a size pill updates the primary CTA price',
      (WidgetTester tester) async {
    await _pumpPdp(tester, DetailPage.catalog(_catalogItem()), cartBloc);

    await tester.tap(find.text('500ml · ${formatRupees(292)}'));
    await tester.pumpAndSettle();

    expect(find.text('Add to cart · ${formatRupees(292)}'), findsOneWidget);
  });

  testWidgets('hero "Select options" opens the shared size sheet',
      (WidgetTester tester) async {
    await _pumpPdp(tester, DetailPage.catalog(_catalogItem()), cartBloc);

    await tester.tap(find.text('Select options'));
    await tester.pumpAndSettle();

    // The shared sheet (also used by Menu / Home quick-add) is on screen.
    expect(find.text('Choose a size'), findsOneWidget);
    expect(find.text('Pineapple Delight'), findsWidgets);
  });

  testWidgets('"Choose quantity" opens the same size sheet',
      (WidgetTester tester) async {
    await _pumpPdp(tester, DetailPage.catalog(_catalogItem()), cartBloc);

    await tester.tap(find.text('Choose quantity'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a size'), findsOneWidget);
  });

  testWidgets('legacy Product entry point hides catalog-only affordances',
      (WidgetTester tester) async {
    final Product legacy = Product(
      'Pineapple Delight',
      'Cold-pressed pineapple with a squeeze of lime.',
      '₹149',
      'assets/pineapple.png',
      12,
    );

    await _pumpPdp(tester, DetailPage.legacy(legacy), cartBloc);

    expect(find.text('Pineapple Delight'), findsOneWidget);
    expect(find.text('Select options'), findsNothing);
    expect(find.text('Choose quantity'), findsNothing);
    expect(find.text('Weekly subscription'), findsOneWidget);
  });

  testWidgets('description, rating and purchase options render',
      (WidgetTester tester) async {
    await _pumpPdp(tester, DetailPage.catalog(_catalogItem()), cartBloc);

    expect(
      find.text('Cold-pressed pineapple with a squeeze of lime.'),
      findsOneWidget,
    );
    expect(find.text('4.8'), findsWidgets);
    expect(find.text('Purchase option'), findsOneWidget);
    expect(find.text('One-time purchase'), findsOneWidget);
    expect(find.text('Weekly subscription'), findsOneWidget);
    // Weekly plans price themselves on their own screen — no invented amount.
    expect(find.text('View plans'), findsOneWidget);
    expect(find.text('Add to cart · ${formatRupees(149)}'), findsOneWidget);
  });

  testWidgets('choosing the weekly subscription swaps the pinned CTA',
      (WidgetTester tester) async {
    await _pumpPdp(tester, DetailPage.catalog(_catalogItem()), cartBloc);

    await tester.tap(find.text('Weekly subscription'));
    await tester.pumpAndSettle();

    expect(find.text('View weekly plans'), findsOneWidget);
    expect(find.text('Add to cart · ${formatRupees(149)}'), findsNothing);

    await tester.tap(find.text('One-time purchase'));
    await tester.pumpAndSettle();

    expect(find.text('Add to cart · ${formatRupees(149)}'), findsOneWidget);
    expect(find.text('View weekly plans'), findsNothing);
  });
}
