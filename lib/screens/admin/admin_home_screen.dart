// lib/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/user_model.dart' as um;

import 'package:urban_market/providers/order_provider.dart';
import 'package:urban_market/providers/product_provider.dart';
import 'package:urban_market/widgets/admin_drawer.dart';
import 'package:urban_market/services/firestore_service.dart';

class AdminHomeScreen extends StatefulWidget {
  static const routeName = '/admin';

  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).listenToOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
      ),
      drawer: const AdminDrawer(),
      body: _buildBody(context),
    );
  }



  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bienvenido, Administrador',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildStatsCard(),
            const SizedBox(height: 20),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final firestoreService = FirestoreService();
    return StreamBuilder<List<um.UserModel>>(
      stream: firestoreService.getUsersStream(),
      builder: (context, userSnapshot) {
        return Consumer2<ProductProvider, OrderProvider>(
          builder: (context, productProvider, orderProvider, child) {
            final tiendas = productProvider.stores.length.toString();
            final pedidos = orderProvider.orders.length.toString();
            final usuarios = userSnapshot.hasData
                ? userSnapshot.data!.length.toString()
                : '-';

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Tiendas', tiendas, Icons.store),
                    _buildStatItem('Pedidos', pedidos, Icons.shopping_cart),
                    _buildStatItem('Usuarios', usuarios, Icons.people),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.deepPurple),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Acciones Rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionCard(
                context,
                'Gestionar Tiendas',
                Icons.store,
                Colors.green,
                () => Navigator.pushNamed(context, '/admin-manage-stores')),
            _buildActionCard(
                context,
                'Gestionar Usuarios',
                Icons.people,
                Colors.blue,
                () => Navigator.pushNamed(context, '/admin-manage-users')),
            _buildActionCard(
                context,
                'Gestionar Pedidos',
                Icons.shopping_cart,
                Colors.orange,
                () => Navigator.pushNamed(context, '/admin-manage-orders')),
            _buildActionCard(
                context,
                'Panel de Control',
                Icons.dashboard,
                Colors.purple,
                () => Navigator.pushNamed(context, '/admin-dashboard')),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
