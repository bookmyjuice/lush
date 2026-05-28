/// Unit tests for one-time order flow.
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/CartRepository/cart_repository.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';
import 'package:lush/bloc/CartBloc/cart_state.dart';
import 'package:lush/views/models/cart_item.dart';
import 'package:lush/views/models/item.dart';
import 'package:lush/views/models/one_time_order_item.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements CartRepository {}

Item createTestItem({String id = 'item-1', String name = 'Test Juice', String size = '200ml'}) {
  return Item(id: id, name: name, servingSize: size);
}
ItemPrice createTestPrice({String id = 'price-1', String name = '200ml', double price = 99.0}) {
  return ItemPrice(id: id, name: name, price: price);
}
CartItem createTestCartItem({String itemId = 'item-1', String priceId = 'price-1', int quantity = 1, double price = 99.0}) {
  return CartItem(item: createTestItem(id: itemId), quantity: quantity, selectedPrice: createTestPrice(id: priceId, price: price));
}

void main() {
  group('OneTimeOrderItem model', () {
    test('priceInRupees = priceInPaise / 100', () {
      final item = OneTimeOrderItem(itemId:'abc',itemPriceId:'abc-w',name:'Test',family:'delight',size:'200ml',priceInPaise:69900);
      expect(item.priceInRupees, 699.0);
    });
    test('totalPaise = priceInPaise × quantity', () {
      final item = OneTimeOrderItem(itemId:'abc',itemPriceId:'abc-w',name:'Test',family:'delight',size:'200ml',priceInPaise:69900,quantity:3);
      expect(item.totalPaise, 209700);
    });
    test('totalRupees = totalPaise / 100', () {
      final item = OneTimeOrderItem(itemId:'abc',itemPriceId:'abc-w',name:'Test',family:'delight',size:'200ml',priceInPaise:69900,quantity:2);
      expect(item.totalRupees, 1398.0);
    });
    test('copyWith preserves unchanged fields', () {
      final original = OneTimeOrderItem(itemId:'abc',itemPriceId:'abc-w',name:'Test',family:'delight',size:'200ml',priceInPaise:69900);
      final copied = original.copyWith();
      expect(copied.itemId, original.itemId);
      expect(copied.family, original.family);
      expect(copied.size, original.size);
    });
    test('copyWith updates quantity', () {
      final original = OneTimeOrderItem(itemId:'abc',itemPriceId:'abc-w',name:'Test',family:'delight',size:'200ml',priceInPaise:69900);
      final copied = original.copyWith(quantity:5);
      expect(copied.quantity, 5);
      expect(copied.itemId, original.itemId);
    });
    test('toChargebeeLineItem has itemPriceId, quantity, unit_price', () {
      final item = OneTimeOrderItem(itemId:'abc',itemPriceId:'abc-w',name:'Test',family:'delight',size:'200ml',priceInPaise:69900,quantity:2);
      final li = item.toChargebeeLineItem();
      expect(li['item_price_id'], 'abc-w');
      expect(li['quantity'], 2);
      expect(li['unit_price'], 69900);
    });
  });

  group('CartBloc', () {
    late MockCartRepository mockRepo;
    setUp(() { TestWidgetsFlutterBinding.ensureInitialized(); mockRepo = MockCartRepository(); });

    blocTest<CartBloc, CartState>(
      'AddToCart emits CartLoaded with item',
      build: () { when(()=>mockRepo.getCartItems()).thenAnswer((_) async =>[]); when(()=>mockRepo.saveCartItems(any())).thenAnswer((_)=>Future.value()); return CartBloc(mockRepo); },
      act: (bloc)=>bloc.add(AddToCart(createTestCartItem(itemId:'i1',priceId:'p1'))),
      expect: ()=>[isA<CartLoaded>()],
      verify: (bloc) { expect((bloc.state as CartLoaded).items.length, 1); },
    );
    blocTest<CartBloc, CartState>(
      'AddToCart same itemPriceId increments quantity',
      build: () { final e=createTestCartItem(itemId:'i1',priceId:'p1',quantity:2); when(()=>mockRepo.getCartItems()).thenAnswer((_) async =>[e]); when(()=>mockRepo.saveCartItems(any())).thenAnswer((_)=>Future.value()); return CartBloc(mockRepo); },
      act: (bloc) async { bloc.add(LoadCart()); await Future.delayed(const Duration(milliseconds:50)); bloc.add(AddToCart(createTestCartItem(itemId:'i1',priceId:'p1',quantity:3))); },
      expect: ()=>[isA<CartLoading>(),isA<CartLoaded>(),isA<CartLoaded>()],
      verify: (bloc) { final s = bloc.state as CartLoaded; expect(s.items.length,1); expect(s.items.first.quantity,5); },
    );
    blocTest<CartBloc, CartState>(
      'ClearCart empties the cart',
      build: () { when(()=>mockRepo.clearCart()).thenAnswer((_)=>Future.value()); return CartBloc(mockRepo); },
      act: (bloc)=>bloc.add(ClearCart()),
      expect: ()=>[isA<CartLoaded>()],
      verify: (bloc) { expect((bloc.state as CartLoaded).items, isEmpty); },
    );
    blocTest<CartBloc, CartState>(
      'PlaceOneTimeOrder emits Loading then OrderPlaced',
      build: () { when(()=>mockRepo.clearCart()).thenAnswer((_)=>Future.value()); return CartBloc(mockRepo); },
      act: (bloc)=>bloc.add(PlaceOneTimeOrder(items:[],deliveryAddress:'addr',deliveryDate:DateTime(2026,5,29))),
      expect: ()=>[isA<CartLoading>(),isA<OrderPlaced>(),isA<CartLoaded>()],
      wait: const Duration(seconds: 2),
    );
  });
}