// lib/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/order_model.dart' as om;
import 'package:urban_market/models/user_model.dart' as um;
import 'package:urban_market/providers/auth_provider.dart' as auth;
import 'package:urban_market/providers/order_provider.dart';
import 'package:urban_market/providers/product_provider.dart';
import 'package:urban_market/services/firestore_service.dart';
import 'package:urban_market/widgets/admin_balance_card.dart';

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
    // Data is now loaded by providers automatically
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authProvider = Provider.of<auth.AuthProvider>(context, listen: false);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Urban Market',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('Administrador',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Gestionar Tiendas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin-manage-stores');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Gestionar Usuarios'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin-manage-users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Gestionar Pedidos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin-manage-orders');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              final productProvider =
                  Provider.of<ProductProvider>(context, listen: false);
              final orderProvider =
                  Provider.of<OrderProvider>(context, listen: false);

              // Clean up listeners before logging out
              productProvider.clearListeners();
              orderProvider.clearListeners();

              authProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    if (orderProvider.isLoading || productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
            const AdminBalanceCard(), // New Balance Card
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
            _buildRecentOrders(context),
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
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Consumer2<ProductProvider, OrderProvider>(
          builder: (context, productProvider, orderProvider, child) {
            final tiendas = productProvider.stores.length.toString();
            final pedidos = orderProvider.orders.length.toString();
            final usuarios = userSnapshot.hasData
                ? userSnapshot.data!.length.toString()
                : '0';

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
                Icons.receipt_long,
                Colors.orange,
                () => Navigator.pushNamed(context, '/admin-manage-orders')),
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

  Widget _buildRecentOrders(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders.take(5).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pedidos Recientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (orders.isEmpty)
              const Text('No hay pedidos recientes.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text('Pedido #${order.id.substring(0, 6)}'),
                    subtitle: Text('Cliente: ${order.userName}'),
                    trailing: Chip(
                      label: Text(order.status.name),
                      backgroundColor: _getStatusColor(order.status),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(om.OrderStatus status) {
    switch (status) {
      case om.OrderStatus.pending:
        return Colors.orange;
      case om.OrderStatus.confirmed:
        return Colors.blueAccent;
      case om.OrderStatus.inProgress:
        return Colors.blue;
      case om.OrderStatus.outForDelivery:
        return Colors.purple;
      case om.OrderStatus.delivered:
        return Colors.green;
      case om.OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
