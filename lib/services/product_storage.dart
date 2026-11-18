import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

// ============================================================
// STORAGE LAYER  (dart:io file I/O)
// ============================================================

class ProductStorage {
  static const String _fileName = 'products.txt';

  /// Returns the File object pointing to products.txt
  static Future<File> _getFile() async {
    final dir = Directory.systemTemp;
    return File('${dir.path}${Platform.pathSeparator}$_fileName');
  }

  /// READ — Load all products from products.txt
  static Future<List<Product>> loadProducts() async {
    try {
      final file = await _getFile();

      if (!await file.exists()) {
        return <Product>[];
      }

      final content = await file.readAsString();

      final lines = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty);

      return lines.map((line) => Product.fromCsv(line)).toList();
    } catch (e) {
      debugPrint('Error loading products: $e');
      return <Product>[];
    }
  }

  /// WRITE — Rewrite products.txt with the current list
  static Future<void> saveProducts(List<Product> products) async {
    final file = await _getFile();
    final content = products.map((p) => p.toCsv()).join('\n');
    await file.writeAsString(content);
  }

  /// Called once at app start. Seeds sample data if the file is missing.
  static Future<void> seedIfEmpty() async {
    final file = await _getFile();
    if (await file.exists()) return;

    final samples = <Product>[
      const Product(
        code: 'PRD001',
        name: 'Coca-Cola 2L',
        category: 'Beverages',
        price: 24.99,
        quantity: 35,
      ),
      const Product(
        code: 'PRD002',
        name: 'White Bread',
        category: 'Bakery',
        price: 18.50,
        quantity: 12,
      ),
      const Product(
        code: 'PRD003',
        name: 'Fresh Milk 2L',
        category: 'Dairy',
        price: 32.99,
        quantity: 4,
      ),
      const Product(
        code: 'PRD004',
        name: 'Washing Powder 2kg',
        category: 'Household',
        price: 79.99,
        quantity: 0,
      ),
      const Product(
        code: 'PRD005',
        name: 'USB Keyboard',
        category: 'Electronics',
        price: 199.99,
        quantity: 8,
      ),
    ];

    await saveProducts(samples);
  }
}