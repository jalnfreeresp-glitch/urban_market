import 'package:flutter/material.dart';
import 'package:urban_market/models/product_model.dart';
import 'package:urban_market/models/store_model.dart';
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
import 'package:urban_market/screens/seller/orders_screen.dart';
import 'package:urban_market/screens/seller/products_screen.dart';
import 'package:urban_market/screens/seller/seller_home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Rutas Admin
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      case '/admin-manage-stores':
        return MaterialPageRoute(builder: (_) => const ManageStoresScreen());
      case '/admin-manage-users':
        return MaterialPageRoute(builder: (_) => const ManageUsersScreen());
      case '/admin-manage-orders':
        return MaterialPageRoute(builder: (_) => const ManageOrdersScreen());

      // Rutas Customer
      case '/customer':
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());
      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case '/stores':
        return MaterialPageRoute(builder: (_) => const StoresScreen());
      case '/store-products':
        final store = settings.arguments as StoreModel;
        return MaterialPageRoute(
            builder: (_) => StoreProductsScreen(store: store));
      case '/product-detail':
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product));

      // Rutas Seller
      case '/seller':
        return MaterialPageRoute(builder: (_) => const SellerHomeScreen());
      case '/products':
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      case '/orders':
        return MaterialPageRoute(builder: (_) => const OrdersScreen());

      // Ruta Delivery
      case '/delivery':
        return MaterialPageRoute(builder: (_) => const DeliveryHomeScreen());

      // Ruta por defecto
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
