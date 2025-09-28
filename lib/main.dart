import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/app_router.dart';
import 'package:urban_market/firebase_options.dart';
import 'package:urban_market/models/user_model.dart' as um;
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/providers/cart_provider.dart';
import 'package:urban_market/providers/order_provider.dart';
import 'package:urban_market/providers/product_provider.dart';
import 'package:urban_market/screens/admin/admin_home_screen.dart';
import 'package:urban_market/screens/customer/customer_home_screen.dart';
import 'package:urban_market/screens/delivery/delivery_home_screen.dart';
import 'package:urban_market/screens/login_screen.dart';
import 'package:urban_market/screens/seller/seller_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // ChangeNotifierProxyProvider permite que un provider dependa de otro.
        // Aquí, ProductProvider y OrderProvider necesitan AuthProvider para saber qué usuario está logueado.
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create: (_) => ProductProvider(null),
          update: (_, auth, previous) => ProductProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (_) => OrderProvider(null),
          update: (_, auth, previous) => OrderProvider(auth),
        ),
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const AuthWrapper(),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Este Widget gestiona qué pantalla mostrar basado en el estado de autenticación.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.user == null) {
      return const LoginScreen();
    } else {
      return _getHomeScreen(authProvider.user!);
    }
  }

  Widget _getHomeScreen(um.UserModel user) {
    // Convertimos el rol a minúsculas para una comparación robusta.
    switch (user.role.toLowerCase()) {
      case 'cliente':
        return const CustomerHomeScreen();
      case 'vendedor':
        return const SellerHomeScreen();
      case 'administrador':
        return const AdminHomeScreen();
      case 'repartidor':
        return const DeliveryHomeScreen();
      default:
        // Si el rol no se reconoce, se envía al login por seguridad.
        return const LoginScreen();
    }
  }
}
