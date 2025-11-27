import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dhandha/theme.dart';
import 'package:dhandha/services/storage_service.dart';
import 'package:dhandha/services/product_service.dart';
import 'package:dhandha/services/customer_service.dart';
import 'package:dhandha/services/sale_service.dart';
import 'package:dhandha/services/expense_service.dart';
import 'package:dhandha/services/vendor_service.dart';
import 'package:dhandha/screens/purchase_orders_screen.dart';
import 'package:dhandha/services/settings_service.dart';
import 'package:dhandha/providers/cart_provider.dart';
import 'package:dhandha/screens/billing_screen.dart';
import 'package:dhandha/screens/payment_screen.dart';
import 'package:dhandha/screens/dashboard_screen.dart';
import 'package:dhandha/screens/inventory_screen.dart';
import 'package:dhandha/screens/customers_screen.dart';
import 'package:dhandha/screens/settings_screen.dart';
import 'package:dhandha/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await StorageService.initialize();
    await SettingsService.initializeDefaultSettings();
    await ProductService.initializeSampleData();
    await CustomerService.initializeSampleData();
    await VendorService.initializeSampleData();
    await SaleService.initializeSampleData();
    await ExpenseService.initializeSampleData();
    debugPrint('✅ Dhandha initialized successfully');
  } catch (e) {
    debugPrint('❌ Initialization error: $e');
  }

  runApp(const DhandhaApp());
}

class DhandhaApp extends StatelessWidget {
  const DhandhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp.router(
        title: 'Dhandha POS',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'billing',
      pageBuilder: (context, state) => NoTransitionPage(
        child: MainShell(currentIndex: 0, child: const BillingScreen()),
      ),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      pageBuilder: (context, state) => NoTransitionPage(
        child: MainShell(currentIndex: 1, child: const DashboardScreen()),
      ),
    ),
    GoRoute(
      path: '/inventory',
      name: 'inventory',
      pageBuilder: (context, state) => NoTransitionPage(
        child: MainShell(currentIndex: 2, child: const InventoryScreen()),
      ),
    ),
    GoRoute(
      path: '/customers',
      name: 'customers',
      pageBuilder: (context, state) => NoTransitionPage(
        child: MainShell(currentIndex: 3, child: const CustomersScreen()),
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => NoTransitionPage(
        child: MainShell(currentIndex: 4, child: const SettingsScreen()),
      ),
    ),
    GoRoute(
      path: '/payment',
      name: 'payment',
      pageBuilder: (context, state) => const MaterialPage(
        child: PaymentScreen(),
      ),
    ),
    GoRoute(
      path: '/purchase-orders',
      name: 'purchaseOrders',
      pageBuilder: (context, state) => const MaterialPage(
        child: PurchaseOrdersScreen(),
      ),
    ),
  ],
);
