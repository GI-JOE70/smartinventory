import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_storage.dart';
import 'add_edit_product_screen.dart';

// ============================================================
// PRODUCT DETAIL SCREEN
// ============================================================

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  // -------- EDIT --------
  Future<void> _edit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(existingProduct: _product),
      ),
    );

    // Reload this product from file (it may have been edited)
    final all = await ProductStorage.loadProducts();
    final found = all.firstWhere(
      (p) => p.code == _product.code,
      orElse: () => _product,
    );

    if (!mounted) return;
    setState(() => _product = found);
  }

  // -------- DELETE WITH CONFIRMATION --------
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${_product.name}"?\n\n'
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
    final updated = all.where((p) => p.code != _product.code).toList();
    await ProductStorage.saveProducts(updated);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Color _statusColor() {
    switch (_product.status) {
      case 'Available':
        return Colors.green.shade700;
      case 'Low Stock':
        return Colors.orange.shade800;
      case 'Out of Stock':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product.code),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // ---------- IMAGE ----------
                CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.indigo.shade50,
                  child: ClipOval(
                    child: Image.asset(
                      _product.imagePath,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.inventory_2,
                        size: 70,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ---------- NAME ----------
                Text(
                  _product.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // ---------- CATEGORY ----------
                Text(
                  _product.category,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),

                const Divider(),

                // ---------- DETAILS ----------
                _DetailRow(label: 'Product Code', value: _product.code),
                _DetailRow(
                  label: 'Unit Price',
                  value: 'R${_product.price.toStringAsFixed(2)}',
                ),
                _DetailRow(
                  label: 'Quantity in Stock',
                  value: '${_product.quantity}',
                ),
                _DetailRow(
                  label: 'Status',
                  value: _product.status,
                  valueColor: _statusColor(),
                ),

                const SizedBox(height: 28),

                // ---------- ACTIONS ----------
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _edit,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _delete,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SMALL HELPER: ONE DETAIL ROW
// ============================================================

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}