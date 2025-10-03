// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:urban_market/models/product_model.dart' as pm;
import 'package:urban_market/models/store_model.dart' as sm;
import 'package:urban_market/screens/admin/admin_home_screen.dart';
import 'package:urban_market/screens/admin/admin_seller_balances_screen.dart';
import 'package:urban_market/screens/admin/manage_orders_screen.dart';
import 'package:urban_market/screens/admin/manage_stores_screen.dart';
import 'package:urban_market/screens/admin/manage_users_screen.dart';
import 'package:urban_market/screens/customer/cart_screen.dart';
import 'package:urban_market/screens/customer/customer_home_screen.dart';
import 'package:urban_market/screens/customer/product_detail_screen.dart';
import 'package:urban_market/screens/customer/store_products_screen.dart';
import 'package:urban_market/screens/customer/stores_screen.dart';
import 'package:urban_market/screens/delivery/delivery_home_screen.dart';
import 'package:urban_market/screens/seller/add_edit_product_screen.dart';
import 'package:urban_market/screens/seller/orders_screen.dart';
import 'package:urban_market/screens/seller/products_screen.dart';
import 'package:urban_market/screens/seller/seller_home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // --- Rutas de Administrador ---
      case AdminHomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());

      case ManageStoresScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ManageStoresScreen());

      case ManageUsersScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ManageUsersScreen());

      case ManageOrdersScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ManageOrdersScreen());

      case AdminSellerBalancesScreen.routeName:
        return MaterialPageRoute(
            builder: (_) => const AdminSellerBalancesScreen());

      // --- Rutas de Cliente ---
      case CustomerHomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());

      case CartScreen.routeName:
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case StoresScreen.routeName:
        return MaterialPageRoute(builder: (_) => const StoresScreen());

      case StoreProductsScreen.routeName:
        // Aseguramos que los argumentos no sean nulos para evitar errores
        if (settings.arguments is sm.StoreModel) {
          final store = settings.arguments as sm.StoreModel;
          return MaterialPageRoute(
              builder: (_) => StoreProductsScreen(store: store));
        }
        break; // Si los argumentos no son correctos, irá al default

      case ProductDetailScreen.routeName:
        if (settings.arguments is pm.ProductModel) {
          final product = settings.arguments as pm.ProductModel;
          return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product));
        }
        break;

      // --- Rutas de Vendedor ---
      case SellerHomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SellerHomeScreen());

      case ProductsScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());

      case OrdersScreen.routeName:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());

      case AddEditProductScreen.routeName:
        final product = settings.arguments as pm.ProductModel?;
        return MaterialPageRoute(
            builder: (_) => AddEditProductScreen(product: product));

      // --- Ruta de Repartidor ---
      case DeliveryHomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const DeliveryHomeScreen());

      // --- Caso por Defecto ---
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Página no encontrada'),
            ),
          ),
        );
    }
    // Este return se añade por si algún `case` con `if` falla, para asegurar que siempre se retorna algo.
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Error en el enrutamiento'),
        ),
      ),
    );
  }
}