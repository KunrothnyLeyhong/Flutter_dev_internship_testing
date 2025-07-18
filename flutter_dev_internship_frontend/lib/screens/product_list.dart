import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_sheet.dart';
import '../model/product.dart';
import '../theme.dart';
import '../widgets/search_field.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    // Load products when page first shows
    Future.microtask(() =>
        context.read<ProductProvider>().fetchProducts());
  }

  Future<void> _openAddSheet() async {
    final provider = context.read<ProductProvider>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(
        title: 'Add Product',
        initialName: '',
        initialPrice: 0,
        initialStock: 0,
        onSubmit: ({
          required String name,
          required double price,
          required int stock,
          String? type,
        }) async {
          return provider.addProduct(
            name: name,
            price: price,
            stock: stock,
          );
        },
      ),
    );
    if (result == true) {
      // success handled in provider fetch
    }
  }

  Future<void> _openEditSheet(Product product) async {
    final provider = context.read<ProductProvider>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(
        title: 'Save Changes',
        initialName: product.productName,
        initialPrice: product.price,
        initialStock: product.stock,
        onSubmit: ({
          required String name,
          required double price,
          required int stock,
          String? type,
        }) async {
          final updated = product.copyWith(
            productName: name,
            price: price,
            stock: stock,
          );
          return provider.updateProduct(updated);
        },
      ),
    );
    if (result == true) {
      // provider already refreshed
    }
  }

  Future<void> _confirmDelete(Product product) async {
    final provider = context.read<ProductProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.productName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deleteProduct(product.productId);
    }
  }

  void _showFilters(BuildContext context) {
    final provider = context.read<ProductProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text(
                    'Sort by',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Price (Low → High)'),
                  onTap: () {
                    provider.sortByPrice(ascending: true);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Price (High → Low)'),
                  onTap: () {
                    provider.sortByPrice(ascending: false);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Stock (Low → High)'),
                  onTap: () {
                    provider.sortByStock(ascending: true);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Stock (High → Low)'),
                  onTap: () {
                    provider.sortByStock(ascending: false);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (_, provider, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Skincare Shop'),
          ),
          body: Column(
            children: [
              // Search field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SearchField(
                  onChanged: provider.applySearch,
                  onFilterPressed: () => _showFilters(context),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Text(
                      'Product Lists',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Body list w/ pull-to-refresh
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                  onRefresh: provider.fetchProducts,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      final product = provider.products[index];
                      return ProductCard(
                        product: product,
                        onEdit: () => _openEditSheet(product),
                        onDelete: () => _confirmDelete(product),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openAddSheet,
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: _BottomNav(currentIndex: 0),
        );
      },
    );
  }
}
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppTheme.sageDark,
      unselectedItemColor: AppTheme.textLight,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Product Lists'),
        // BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onTap: (_) {}, // Only one tab for now
    );
  }
}
