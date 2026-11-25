import 'package:flutter/material.dart' show RefreshIndicator, Offset;
import 'package:flutter_test/flutter_test.dart';
import 'package:gemstore_pixel/cubit/store_cubit.dart';
import 'package:gemstore_pixel/data/product_repository.dart';
import 'package:gemstore_pixel/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FakeRepository extends ProductRepository {
  bool fail = false;
  @override
  Future<List<Product>> load() async {
    if (fail) throw const FormatException();
    return [
      for (final (id, price, category) in [
        ('b', 45.0, 'Women'),
        ('a', 29.0, 'Men'),
      ])
        Product.fromJson({
          'id': id,
          'name': 'Product $id',
          'category': category,
          'description': 'Cotton',
          'price': price,
          'image': 0,
          'sizes': ['S', 'M'],
          'colors': ['Black'],
        }),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Bundled JSON loads asynchronously', () async {
    final products = await ProductRepository().load();
    expect(products.length, 6);
    expect(products.map((p) => p.id).toSet().length, 6);
  });
  test('Search, filters, sorting, favorites, cart and retry', () async {
    final repo = FakeRepository();
    final cubit = StoreCubit(repo);
    addTearDown(cubit.close);
    expect(cubit.state.status, CatalogStatus.loading);
    await cubit.load();
    expect(cubit.state.status, CatalogStatus.success);
    cubit.sort(ProductSort.priceLow);
    expect(cubit.state.visible.first.id, 'a');
    cubit.sort(ProductSort.priceHigh);
    expect(cubit.state.visible.first.id, 'b');
    cubit.search('PRODUCT A');
    expect(cubit.state.visible.single.id, 'a');
    cubit.reset();
    cubit.category('Beauty');
    expect(cubit.state.status, CatalogStatus.empty);
    cubit.reset();
    cubit.favoritesOnly(true);
    expect(cubit.state.status, CatalogStatus.empty);
    cubit.favorite('b');
    expect(cubit.state.visible.single.id, 'b');
    final p = cubit.state.visible.single;
    cubit.add(p, 'S', 'Black');
    cubit.add(p, 'S', 'Black');
    expect(cubit.state.count, 2);
    expect(cubit.state.total, 90);
    cubit.add(p, 'M', 'Black');
    expect(cubit.state.cart.length, 2);
    cubit.quantity(cubit.state.cart.first.key, -1);
    expect(cubit.state.count, 2);
    cubit.remove(cubit.state.cart.first.key);
    expect(cubit.state.count, 1);
    cubit.clearCart();
    expect(cubit.state.total, 0);
    repo.fail = true;
    await cubit.load();
    expect(cubit.state.status, CatalogStatus.error);
    repo.fail = false;
    await cubit.load();
    expect(cubit.state.favorites, contains('b'));
  });
  testWidgets('Product navigation, favorite and add to bag', (tester) async {
    final cubit = StoreCubit(FakeRepository());
    addTearDown(cubit.close);
    await cubit.load();
    await tester.pumpWidget(
      BlocProvider.value(value: cubit, child: const GemStoreApp()),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(RefreshIndicator), const Offset(0, -420));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Product b'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Toggle favorite'));
    await tester.pumpAndSettle();
    expect(cubit.state.favorites, contains('b'));
    await tester.tap(find.text('Add to cart'));
    await tester.pumpAndSettle();
    expect(cubit.state.count, 1);
    await tester.tap(find.byTooltip('Shopping bag'));
    await tester.pumpAndSettle();
    expect(find.text('Shopping bag (1)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
