// lib/main.dart (versión refactorizada y actualizada)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:urban_market/app_router.dart'; // 1. Importa tu nuevo router
import 'package:urban_market/firebase_options.dart';
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/providers/cart_provider.dart';
import 'package:urban_market/providers/order_provider.dart';
import 'package:urban_market/providers/product_provider.dart';

// Importa las pantallas que necesitará el AuthWrapper
import 'package:urban_market/screens/login_screen.dart';
import 'package:urban_market/screens/customer/customer_home_screen.dart';
import 'package:urban_market/screens/seller/seller_home_screen.dart';
import 'package:urban_market/screens/admin/admin_home_screen.dart';
import 'package:urban_market/screens/delivery/delivery_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => ProductProvider()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider()),
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
      // 2. El home ahora es el widget que decide qué pantalla mostrar
      home: const AuthWrapper(),
      // 3. Usa la clase AppRouter para generar todas las demás rutas
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

// 4. Widget para gestionar el flujo de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Muestra un indicador de carga mientras se verifica el estado de auth
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si no hay usuario, muestra la pantalla de Login
    if (authProvider.user == null) {
      return const LoginScreen();
    } else {
      // Si hay un usuario, redirige según su rol
      // NOTA: Asegúrate de que tu modelo 'user' en AuthProvider tenga una propiedad 'role'
      switch (authProvider.user!.role) {
        case 'Cliente':
          return const CustomerHomeScreen();
        case 'Vendedor':
          return const SellerHomeScreen();
        case 'Administrador':
          return const AdminHomeScreen();
        case 'Repartidor':
          return const DeliveryHomeScreen();
        default:
          // Si el rol no se reconoce, se envía al login por seguridad
          return const LoginScreen();
      }
    }
  }
}
