import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/scan/scan_cart_screen.dart';
import 'features/billing/bill_summary_screen.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/history/billing_history_screen.dart';
import 'features/customer/shop_selection_screen.dart';
import 'features/customer/product_price_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Android only)
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase initialization error: $e');
    }
  }
  // For Web: Firebase is initialized via index.html scripts
  
  runApp(const SmartScanApp());
}

class SmartScanApp extends StatelessWidget {
  const SmartScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartScan',
      theme: ThemeData(
        fontFamily: 'Arial',
        primaryColor: const Color(0xFF031B3A),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/scan': (context) => const ScanCartScreen(),
        '/generate-bill': (context) => const BillSummaryScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/history': (context) => const BillingHistoryScreen(),
        '/shop-selection': (context) => const ShopSelectionScreen(),
        '/product-price-scanner': (context) => const ProductPriceScannerScreen(),
      },
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF4FC3F7),
              Color(0xFF0A3D62),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 90,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                "Welcome To Smart Scan",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black54,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Choose Your Mode",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),
              CustomButton(
                title: "Customer",
                icon: Icons.person,
                onTap: () {
                  Navigator.pushNamed(context, '/shop-selection');
                },
              ),
              const SizedBox(height: 25),
              CustomButton(
                title: "Shopkeeper",
                icon: Icons.store,
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const CustomButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B4965),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
            side: const BorderSide(
              color: Colors.black,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
