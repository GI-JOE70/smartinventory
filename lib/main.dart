import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/product_storage.dart';

// ============================================================
// MAIN ENTRY POINT
// Student Numbers : <student number>
// Student Names   : <name>
// ============================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProductStorage.seedIfEmpty();
  runApp(const InventoryApp());
}

// ============================================================
// ROOT WIDGET
// ============================================================

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartMart Inventory',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomeScreen(),
    );
  }
}