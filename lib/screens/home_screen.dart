import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_storage.dart';
import '../widgets/product_list_card.dart';
import 'add_edit_product_screen.dart';
import 'product_detail_screen.dart';

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // -------- LOAD --------
  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    final loaded = await ProductStorage.loadProducts();

    if (!mounted) return;
    setState(() {
      _products = loaded;
      _isLoading = false;
    });
  }

  // -------- NAVIGATE: DETAIL --------
  Future<void> _openDetail(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
    await _loadProducts();
  }

  // -------- NAVIGATE: ADD --------
  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditProductScreen(),
      ),
    );
    await _loadProducts();
  }

  // -------- DELETE WITH CONFIRMATION --------
  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.name}"?\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final all = await ProductStorage.loadProducts();
    final updated = all.where((p) => p.code != product.code).toList();
    await ProductStorage.saveProducts(updated);

    await _loadProducts();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${product.name}" deleted')),
    );
  }

  // -------- BUILD --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartMart Inventory'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No products yet.\nTap + to add your first product.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ProductListCard(
                      product: product,
                      onTap: () => _openDetail(product),
                      onLongPress: () => _confirmDelete(product),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Product',
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}