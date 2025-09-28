import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/user_model.dart' as um;
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/providers/order_provider.dart';
import 'package:urban_market/providers/product_provider.dart';
import 'package:urban_market/services/firestore_service.dart';

// 1. Se convierte en un StatefulWidget
class AdminHomeScreen extends StatefulWidget {
  static const routeName = '/admin';

  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // 2. La lógica que cambia el estado se mueve a initState
  @override
  void initState() {
    super.initState();
    // Se usa addPostFrameCallback para asegurar que el build haya terminado
    // antes de llamar al provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // La llamada al provider se hace aquí, fuera del método build.
      Provider.of<OrderProvider>(context, listen: false).listenToOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    // El método build ahora solo se enfoca en construir la UI.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Gestionar Pedidos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin-manage-orders');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {
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
