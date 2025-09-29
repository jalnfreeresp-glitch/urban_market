// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:urban_market/models/product_model.dart' as pm;
import 'package:urban_market/models/store_model.dart' as sm;
import 'package:urban_market/screens/admin/admin_dashboard_screen.dart';
import 'package:urban_market/screens/admin/admin_home_screen.dart';
import 'package:urban_market/screens/admin/manage_orders_screen.dart';
import 'package:urban_market/screens/admin/manage_stores_screen.dart';
import 'package:urban_market/screens/admin/manage_users_screen.dart';
import 'package:urban_market/screens/customer/cart_screen.dart';
import 'package:urban_market/screens/customer/customer_home_screen.dart';
import 'package:urban_market/screens/customer/product_detail_screen.dart';
import 'package:urban_market/screens/customer/store_products_screen.dart';
import 'package:urban_market/screens/customer/stores_screen.dart';
import 'package:urban_market/screens/delivery/delivery_home_screen.dart';
import 'package:urban_market/screens/login_screen.dart';
import 'package:urban_market/screens/seller/add_edit_product_screen.dart';
import 'package:urban_market/screens/seller/orders_screen.dart';
import 'package:urban_market/screens/seller/products_screen.dart';
import 'package:urban_market/screens/seller/seller_home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AdminDashboardScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case AdminHomeScreen.routeName:
        return MaterialPageRoute(
            builder: (_) =>
                const AdminDashboardScreen()); // Redirigir al panel de control
      case ManageStoresScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ManageStoresScreen());
      case ManageUsersScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ManageUsersScreen());
      case ManageOrdersScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ManageOrdersScreen());

      case CustomerHomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());
      case CartScreen.routeName:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case StoresScreen.routeName:
        return MaterialPageRoute(builder: (_) => const StoresScreen());
      case StoreProductsScreen.routeName:
        final store = settings.arguments as sm.StoreModel;
        return MaterialPageRoute(
            builder: (_) => StoreProductsScreen(store: store));
      case ProductDetailScreen.routeName:
        final product = settings.arguments as pm.ProductModel;
        return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product));

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

      case DeliveryHomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const DeliveryHomeScreen());

      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
