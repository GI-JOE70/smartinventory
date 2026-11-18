import 'package:flutter/material.dart';
import '../models/product.dart';

// ============================================================
// PRODUCT LIST CARD  (reusable row)
// ============================================================

class ProductListCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ProductListCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onLongPress,
  });

  Color _statusColor() {
    switch (product.status) {
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.indigo.shade50,
          child: ClipOval(
            child: Image.asset(
              product.imagePath,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.inventory_2,
                color: Colors.indigo.shade700,
              ),
            ),
          ),
        ),
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${product.code} • R${product.price.toStringAsFixed(2)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Text(
          product.status,
          style: TextStyle(
            color: _statusColor(),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}