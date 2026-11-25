import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/store_cubit.dart';
import '../data/product_repository.dart';
import '../widgets/product_photo.dart';

String money(double value) => '\$${value.toStringAsFixed(2)}';
void openProduct(BuildContext context, Product p) => Navigator.push(
  context,
  MaterialPageRoute<void>(builder: (_) => ProductScreen(product: p)),
);

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<StoreCubit, StoreState>(
    builder: (context, s) {
      final cubit = context.read<StoreCubit>();
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'GemStore',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_outlined),
              onPressed:
                  () => showDialog<void>(
                    context: context,
                    builder:
                        (c) => AlertDialog(
                          title: const Text('Notifications'),
                          content: const Text(
                            'Welcome to GemStore. Explore the Autumn Collection and save your favorite styles.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                  ),
            ),
          ],
        ),
        drawer: Drawer(
          child: SafeArea(
            child: ListView(
              children: [
                const ListTile(
                  title: Text(
                    'GemStore',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                ...['All', 'Women', 'Men', 'Accessories', 'Beauty'].map(
                  (category) => ListTile(
                    title: Text(category),
                    onTap: () {
                      cubit.category(category);
                      cubit.favoritesOnly(false);
                      Navigator.pop(context);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Shopping bag'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const CartScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: s.favoritesOnly ? 1 : 0,
          onDestinationSelected: (i) {
            if (i == 2) {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const CartScreen()),
              );
            } else {
              cubit.favoritesOnly(i == 1);
            }
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.favorite_border),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Badge(
                label: Text('${s.count}'),
                isLabelVisible: s.count > 0,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              label: 'Bag',
            ),
          ],
        ),
        body:
            s.status == CatalogStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : s.status == CatalogStatus.error
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Could not load the local catalog.'),
                      FilledButton(
                        onPressed: cubit.load,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: cubit.load,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(22),
                        children: [
                          TextFormField(
                            key: ValueKey(s.query.isEmpty),
                            initialValue: s.query,
                            onChanged: cubit.search,
                            decoration: InputDecoration(
                              hintText: 'Search products',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                tooltip: 'Clear search',
                                onPressed: () => cubit.search(''),
                                icon: const Icon(Icons.close),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children:
                                ['All', 'Women', 'Men', 'Accessories', 'Beauty']
                                    .map(
                                      (c) => ChoiceChip(
                                        label: Text(c),
                                        selected: s.category == c,
                                        onSelected: (_) => cubit.category(c),
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 22),
                          InkWell(
                            onTap: () {
                              cubit.reset();
                              cubit.category('Women');
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 170,
                              padding: const EdgeInsets.all(26),
                              decoration: BoxDecoration(
                                color: const Color(0xffdcc5b5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 58,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 24),
                                  Expanded(
                                    child: Text(
                                      'Autumn\nCollection\n2021',
                                      style: TextStyle(
                                        fontSize: 29,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s.favoritesOnly
                                      ? 'Your Favorites'
                                      : 'Feature Products',
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: cubit.reset,
                                child: const Text('Show all'),
                              ),
                            ],
                          ),
                          DropdownButton<ProductSort>(
                            value: s.sort,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: ProductSort.featured,
                                child: Text('Featured'),
                              ),
                              DropdownMenuItem(
                                value: ProductSort.priceLow,
                                child: Text('Price: low to high'),
                              ),
                              DropdownMenuItem(
                                value: ProductSort.priceHigh,
                                child: Text('Price: high to low'),
                              ),
                              DropdownMenuItem(
                                value: ProductSort.name,
                                child: Text('Name A–Z'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) cubit.sort(v);
                            },
                          ),
                          if (s.status == CatalogStatus.empty)
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  const Icon(Icons.search_off, size: 48),
                                  const Text('No products found'),
                                  TextButton(
                                    onPressed: cubit.reset,
                                    child: const Text('Reset filters'),
                                  ),
                                ],
                              ),
                            ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: s.visible.length,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 240,
                                  mainAxisExtent: 285,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 18,
                                ),
                            itemBuilder: (context, index) {
                              final p = s.visible[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => openProduct(context, p),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ProductPhoto(p.image),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: IconButton.filledTonal(
                                              tooltip:
                                                  s.favorites.contains(p.id)
                                                      ? 'Remove favorite'
                                                      : 'Add favorite',
                                              onPressed:
                                                  () => cubit.favorite(p.id),
                                              icon: Icon(
                                                s.favorites.contains(p.id)
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      p.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      money(p.price),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      );
    },
  );
}

class ProductScreen extends StatefulWidget {
  final Product product;
  const ProductScreen({required this.product, super.key});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late String size, color;
  @override
  void initState() {
    super.initState();
    size = widget.product.sizes.first;
    color = widget.product.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cubit = context.read<StoreCubit>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product details'),
        actions: [
          BlocBuilder<StoreCubit, StoreState>(
            builder:
                (context, s) => IconButton(
                  tooltip: 'Toggle favorite',
                  onPressed: () => cubit.favorite(p.id),
                  icon: Icon(
                    s.favorites.contains(p.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
          ),
          IconButton(
            tooltip: 'Shopping bag',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const CartScreen()),
                ),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SizedBox(
                height: 420,
                child: Tooltip(
                  message: 'Tap to enlarge',
                  child: InkWell(
                    onTap:
                        () => showDialog<void>(
                          context: context,
                          builder:
                              (photoContext) => Dialog.fullscreen(
                                child: Scaffold(
                                  backgroundColor: Colors.black,
                                  appBar: AppBar(
                                    title: Text(p.name),
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                                  body: InteractiveViewer(
                                    minScale: 1,
                                    maxScale: 4,
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/products/product-${p.image}.jpg',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        ),
                    child: ProductPhoto(p.image),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                p.name,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(money(p.price), style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 20),
              const Text('Color'),
              Wrap(
                spacing: 8,
                children:
                    p.colors
                        .map(
                          (c) => ChoiceChip(
                            label: Text(c),
                            selected: color == c,
                            onSelected: (_) => setState(() => color = c),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 16),
              const Text('Size'),
              Wrap(
                spacing: 8,
                children:
                    p.sizes
                        .map(
                          (s) => ChoiceChip(
                            label: Text(s),
                            selected: size == s,
                            onSelected: (_) => setState(() => size = s),
                          ),
                        )
                        .toList(),
              ),
              ExpansionTile(
                initiallyExpanded: true,
                title: const Text('Description'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(p.description),
                  ),
                ],
              ),
              const ExpansionTile(
                title: Text('Reviews'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No reviews yet for this product.'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Similar Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ...cubit.state.products
                  .where(
                    (other) => other.category == p.category && other.id != p.id,
                  )
                  .map(
                    (other) => ListTile(
                      title: Text(other.name),
                      subtitle: Text(money(other.price)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => openProduct(context, other),
                    ),
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () {
              cubit.add(p, size, color);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${p.name} added • $size • $color'),
                  action: SnackBarAction(
                    label: 'View bag',
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const CartScreen(),
                          ),
                        ),
                  ),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Add to cart'),
            ),
          ),
        ),
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<StoreCubit, StoreState>(
    builder: (context, s) {
      final cubit = context.read<StoreCubit>();
      return Scaffold(
        appBar: AppBar(title: Text('Shopping bag (${s.count})')),
        body:
            s.cart.isEmpty
                ? const Center(child: Text('Your bag is empty.'))
                : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    ...s.cart.map(
                      (item) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.product.name),
                                subtitle: Text(
                                  '${item.size} • ${item.color}\n${money(item.product.price)} each',
                                ),
                                trailing: IconButton(
                                  tooltip: 'Remove item',
                                  onPressed: () => cubit.remove(item.key),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Decrease quantity',
                                    onPressed:
                                        () => cubit.quantity(item.key, -1),
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    tooltip: 'Increase quantity',
                                    onPressed:
                                        () => cubit.quantity(item.key, 1),
                                    icon: const Icon(Icons.add),
                                  ),
                                  const Spacer(),
                                  Text(
                                    money(item.product.price * item.quantity),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Total: ${money(s.total)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder:
                              (c) => AlertDialog(
                                title: const Text('Demo checkout'),
                                content: Text(
                                  '${s.count} item(s) • ${money(s.total)}\nThis is a local demonstration. No payment or real order will be sent.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    child: const Text('Confirm demo order'),
                                  ),
                                ],
                              ),
                        );
                        if (confirmed == true && context.mounted) {
                          cubit.clearCart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Demo order confirmed.'),
                            ),
                          );
                        }
                      },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
      );
    },
  );
}
