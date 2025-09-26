import 'package:flutter/material.dart';
import 'package:urban_market/screens/admin/admin_home_screen.dart';
import 'package:urban_market/screens/customer/customer_home_screen.dart';
import 'package:urban_market/screens/delivery/delivery_home_screen.dart';
import 'package:urban_market/screens/seller/seller_home_screen.dart';

class RoleHomeScreen extends StatelessWidget {
  final String role;
  final String userId;

  const RoleHomeScreen({
    Key? key,
    required this.role,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case 'admin':
        return const AdminHomeScreen();
      case 'customer':
        return const CustomerHomeScreen();
      case 'seller':
        return const SellerHomeScreen();
      case 'delivery':
        return const DeliveryHomeScreen();
      default:
        return const Scaffold(
          body: Center(child: Text('Rol no válido')),
        );
    }
  }
}
