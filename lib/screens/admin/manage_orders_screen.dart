// lib/screens/admin/manage_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/providers/order_provider.dart';
import 'package:urban_market/widgets/admin_drawer.dart';
import 'package:urban_market/widgets/order_card.dart';

class ManageOrdersScreen extends StatefulWidget {
  static const routeName = '/admin-manage-orders';

  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<OrderProvider>(context, listen: false).listenToOrders(
            userId: authProvider.user!.id, role: authProvider.user!.role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Gestionar Pedidos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: const AdminDrawer(),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = orderProvider.orders;
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aún no hay pedidos para mostrar.'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}