// ============================================================
// MODEL LAYER
// Student Numbers : <student number>
// Student Names   : <name>
// ============================================================

class Product {
  final String code;
  final String name;
  final String category;
  final double price;
  final int quantity;

  const Product({
    required this.code,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
  });

  /// Status is DERIVED from quantity — never stored.
  String get status {
    if (quantity <= 0) return 'Out of Stock';
    if (quantity < 10) return 'Low Stock';
    return 'Available';
  }

  /// Image is derived from category — it is NOT stored in the file.
  String get imagePath {
    switch (category) {
      case 'Beverages':
        return 'assets/images/beverages.png';
      case 'Groceries':
        return 'assets/images/groceries.png';
      case 'Bakery':
        return 'assets/images/bakery.png';
      case 'Dairy':
        return 'assets/images/dairy.png';
      case 'Household':
        return 'assets/images/household.png';
      case 'Personal Care':
        return 'assets/images/personal_care.png';
      case 'Electronics':
        return 'assets/images/electronics.png';
      default:
        return 'assets/images/other.png';
    }
  }

  /// Convert this product into one CSV line for products.txt
  String toCsv() {
    return '$code,$name,$category,$price,$quantity,$status';
  }

  /// Build a Product from one CSV line read from products.txt
  factory Product.fromCsv(String line) {
    final parts = line.split(',');
    return Product(
      code: parts[0].trim(),
      name: parts[1].trim(),
      category: parts[2].trim(),
      price: double.parse(parts[3].trim()),
      quantity: int.parse(parts[4].trim()),
    );
  }
}