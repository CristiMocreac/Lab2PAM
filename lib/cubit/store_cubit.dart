import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/product_repository.dart';

enum CatalogStatus { loading, success, empty, error }

enum ProductSort { featured, priceLow, priceHigh, name }

class CartItem {
  final Product product;
  final String size, color;
  final int quantity;
  const CartItem(this.product, this.size, this.color, [this.quantity = 1]);
  String get key => '${product.id}:$size:$color';
}

class StoreState {
  final CatalogStatus status;
  final List<Product> products, visible;
  final Set<String> favorites;
  final List<CartItem> cart;
  final String query, category;
  final ProductSort sort;
  final bool favoritesOnly;
  const StoreState({
    this.status = CatalogStatus.loading,
    this.products = const [],
    this.visible = const [],
    this.favorites = const {},
    this.cart = const [],
    this.query = '',
    this.category = 'All',
    this.sort = ProductSort.featured,
    this.favoritesOnly = false,
  });
  double get total =>
      cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  int get count => cart.fold(0, (sum, item) => sum + item.quantity);
}

class StoreCubit extends Cubit<StoreState> {
  final ProductRepository repository;
  StoreCubit(this.repository) : super(const StoreState());
  Future<void> load() async {
    update(status: CatalogStatus.loading);
    try {
      final products = await repository.load();
      if (!isClosed) update(products: products);
    } catch (_) {
      if (!isClosed) update(status: CatalogStatus.error);
    }
  }

  void search(String value) => update(query: value);
  void category(String value) => update(category: value);
  void sort(ProductSort value) => update(sort: value);
  void favoritesOnly(bool value) => update(favoritesOnly: value);
  void reset() => update(query: '', category: 'All', favoritesOnly: false);
  void favorite(String id) {
    final ids = {...state.favorites};
    if (!ids.add(id)) ids.remove(id);
    update(favorites: ids);
  }

  void add(Product p, String size, String color) {
    final items = [...state.cart];
    final item = CartItem(p, size, color);
    final index = items.indexWhere((i) => i.key == item.key);
    if (index < 0) {
      items.add(item);
    } else {
      final old = items[index];
      items[index] = CartItem(p, size, color, old.quantity + 1);
    }
    update(cart: items);
  }

  void quantity(String key, int delta) {
    final items =
        state.cart
            .map(
              (i) =>
                  i.key == key
                      ? CartItem(i.product, i.size, i.color, i.quantity + delta)
                      : i,
            )
            .where((i) => i.quantity > 0)
            .toList();
    update(cart: items);
  }

  void remove(String key) =>
      update(cart: state.cart.where((i) => i.key != key).toList());
  void clearCart() => update(cart: []);
  void update({
    CatalogStatus? status,
    List<Product>? products,
    Set<String>? favorites,
    List<CartItem>? cart,
    String? query,
    String? category,
    ProductSort? sort,
    bool? favoritesOnly,
  }) {
    final all = products ?? state.products,
        q = query ?? state.query,
        c = category ?? state.category;
    final ids = favorites ?? state.favorites,
        only = favoritesOnly ?? state.favoritesOnly,
        order = sort ?? state.sort;
    final visible =
        all
            .where(
              (p) =>
                  (c == 'All' || p.category == c) &&
                  ('${p.name} ${p.description}'.toLowerCase().contains(
                    q.trim().toLowerCase(),
                  )) &&
                  (!only || ids.contains(p.id)),
            )
            .toList();
    switch (order) {
      case ProductSort.featured:
        break;
      case ProductSort.priceLow:
        visible.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSort.priceHigh:
        visible.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSort.name:
        visible.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    emit(
      StoreState(
        status:
            status ??
            (visible.isEmpty ? CatalogStatus.empty : CatalogStatus.success),
        products: List.unmodifiable(all),
        visible: List.unmodifiable(visible),
        favorites: Set.unmodifiable(ids),
        cart: List.unmodifiable(cart ?? state.cart),
        query: q,
        category: c,
        sort: order,
        favoritesOnly: only,
      ),
    );
  }
}
