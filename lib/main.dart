// lib/main.dart (actualizado)
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:urban_market/models/store_model.dart';
import 'package:urban_market/models/product_model.dart';
import 'package:urban_market/providers/cart_provider.dart';
import 'package:urban_market/providers/product_provider.dart';
import 'package:urban_market/providers/order_provider.dart';
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/screens/login_screen.dart';
import 'package:urban_market/screens/admin/admin_home_screen.dart';
import 'package:urban_market/screens/customer/customer_home_screen.dart';
import 'package:urban_market/screens/delivery/delivery_home_screen.dart';
import 'package:urban_market/screens/seller/seller_home_screen.dart';
import 'package:urban_market/screens/seller/products_screen.dart';
import 'package:urban_market/screens/seller/orders_screen.dart';
import 'package:urban_market/screens/customer/cart_screen.dart';
import 'package:urban_market/screens/customer/stores_screen.dart';
import 'package:urban_market/screens/customer/store_products_screen.dart';
import 'package:urban_market/screens/customer/product_detail_screen.dart';
import 'package:urban_market/screens/admin/manage_stores_screen.dart';
import 'package:urban_market/screens/admin/manage_users_screen.dart';
import 'package:urban_market/screens/admin/manage_orders_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:urban_market/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Si no se puede inicializar Firebase, terminar la aplicación
    rethrow;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider<CartProvider>(create: (ctx) => CartProvider()),
        ChangeNotifierProvider<ProductProvider>(
            create: (ctx) => ProductProvider()),
        ChangeNotifierProvider<OrderProvider>(create: (ctx) => OrderProvider()),
      ],
      child: const UrbanMarketApp(),
    ),
  );
}

class UrbanMarketApp extends StatelessWidget {
  const UrbanMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urban Market',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      onGenerateRoute: (settings) {
        return _generateRoute(settings, context);
      },
      debugShowCheckedModeBanner: false,
    );
  }

  // Función separada para generar rutas
  Route? _generateRoute(RouteSettings settings, BuildContext parentContext) {
    // Cada pantalla debe tener acceso a los providers
    switch (settings.name) {
      case '/admin':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: const AdminHomeScreen(),
          ),
        );
      case '/admin-manage-stores':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: const ManageStoresScreen(),
          ),
        );
      case '/admin-manage-users':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: const ManageUsersScreen(),
          ),
        );
      case '/admin-manage-orders':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: const ManageOrdersScreen(),
          ),
        );
      case '/customer':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: const CustomerHomeScreen(),
          ),
        );
      case '/delivery':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: const DeliveryHomeScreen(),
          ),
        );
      case '/seller':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: const SellerHomeScreen(),
          ),
        );
      case '/products':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: const ProductsScreen(),
          ),
        );
      case '/orders':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: const OrdersScreen(),
          ),
        );
      case '/cart':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: const CartScreen(),
          ),
        );
      case '/stores':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: const StoresScreen(),
          ),
        );
      case '/store-products':
        final store = settings.arguments as Store;
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: StoreProductsScreen(store: store),
          ),
        );
      case '/product-detail':
        final product = settings.arguments as Product?;
        if (product == null) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(
                value: Provider.of<AuthProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<CartProvider>.value(
                value: Provider.of<CartProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<ProductProvider>.value(
                value:
                    Provider.of<ProductProvider>(parentContext, listen: false),
              ),
              ChangeNotifierProvider<OrderProvider>.value(
                value: Provider.of<OrderProvider>(parentContext, listen: false),
              ),
            ],
            child: ProductDetailScreen(product: product),
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
