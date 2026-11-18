import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_storage.dart';

// ============================================================
// ADD / EDIT PRODUCT SCREEN
// One screen handles both: if `existingProduct` is null → Add mode,
// otherwise → Edit mode.
// ============================================================

class AddEditProductScreen extends StatefulWidget {
  final Product? existingProduct;

  const AddEditProductScreen({super.key, this.existingProduct});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _qtyController;

  String? _selectedCategory;
  bool _isSaving = false;

  final List<String> _categories = const [
    'Beverages',
    'Groceries',
    'Bakery',
    'Dairy',
    'Household',
    'Personal Care',
    'Electronics',
    'Other',
  ];

  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;

    _codeController = TextEditingController(text: p?.code ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _qtyController =
        TextEditingController(text: p != null ? p.quantity.toString() : '');

    _selectedCategory = p?.category;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  // -------- PREVIEW IMAGE (derived from category) --------
  String get _previewImagePath {
    switch (_selectedCategory) {
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

  // -------- SAVE --------
  Future<void> _saveProduct() async {
    // 1. Validate
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    setState(() => _isSaving = true);

    // 2. Build new Product
    final newProduct = Product(
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      price: double.parse(_priceController.text.trim()),
      quantity: int.parse(_qtyController.text.trim()),
    );

    // 3. Load current list
    final all = await ProductStorage.loadProducts();

    // 4. Duplicate check (only if ADD, or if code changed during EDIT)
    final codeChanged = !_isEditing ||
        widget.existingProduct!.code != newProduct.code;

    if (codeChanged && all.any((p) => p.code == newProduct.code)) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product code "${newProduct.code}" already exists'),
        ),
      );
      return;
    }

    // 5. Update or add
    if (_isEditing) {
      final index = all.indexWhere(
        (p) => p.code == widget.existingProduct!.code,
      );
      if (index != -1) {
        all[index] = newProduct;
      } else {
        all.add(newProduct);
      }
    } else {
      all.add(newProduct);
    }

    // 6. Write file
    await ProductStorage.saveProducts(all);

    // 7. Return to previous screen
    if (!mounted) return;
    Navigator.pop(context);
  }

  // -------- BUILD --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------- IMAGE PREVIEW ----------
              Center(
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.indigo.shade50,
                  child: ClipOval(
                    child: Image.asset(
                      _previewImagePath,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.inventory_2,
                        size: 55,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _selectedCategory ?? 'Choose a category',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ---------- PRODUCT CODE ----------
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Product Code',
                  hintText: 'e.g. PRD006',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product code is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---------- PRODUCT NAME ----------
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g. Coca-Cola 2L',
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---------- CATEGORY ----------
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              // ---------- UNIT PRICE ----------
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Unit Price (R)',
                  hintText: 'e.g. 24.99',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Unit price is required';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null) {
                    return 'Please enter a valid number';
                  }
                  if (price <= 0) {
                    return 'Price must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---------- QUANTITY ----------
              TextFormField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity in Stock',
                  hintText: 'e.g. 35',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  final qty = int.tryParse(value.trim());
                  if (qty == null) {
                    return 'Please enter a whole number';
                  }
                  if (qty < 0) {
                    return 'Quantity cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // ---------- STATUS HINT ----------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Status is calculated automatically from quantity.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ---------- SAVE ----------
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveProduct,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isEditing ? 'Update Product' : 'Save Product'),
              ),
              const SizedBox(height: 12),

              // ---------- CANCEL ----------
              OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}