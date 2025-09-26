import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/store_model.dart';
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/services/firestore_service.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  Store? _store;

  @override
  void initState() {
    super.initState();
    _fetchStore();
  }

  Future<void> _fetchStore() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final store = await FirestoreService.getStoreByOwner(user.id);
      if (mounted) {
        setState(() {
          _store = store;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Vendedor'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context, authProvider),
      body: _store == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Urban Market',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Vendedor',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Mi Tienda'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('Mis Productos'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/products');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Mis Pedidos'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/orders');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido, ${_store!.name}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(_store!.isOpen ? 'Tienda Abierta' : 'Tienda Cerrada'),
              Switch(
                value: _store!.isOpen,
                onChanged: (value) async {
                  final updatedStore = _store!.copyWith(isOpen: value);
                  await FirestoreService.updateStore(updatedStore);
                  setState(() {
                    _store = updatedStore;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatsCard(),
          const SizedBox(height: 20),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return FutureBuilder<List<int>>(
      future: _fetchSellerStats(),
      builder: (context, snapshot) {
        final productos = snapshot.hasData ? snapshot.data![0].toString() : '-';
        final pedidos = snapshot.hasData ? snapshot.data![1].toString() : '-';
        final ventas = snapshot.hasData ? 'S/. ${snapshot.data![2]}' : '-';
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Estadísticas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        'Productos', productos, Icons.shopping_basket),
                    _buildStatItem('Pedidos', pedidos, Icons.list_alt),
                    _buildStatItem('Ventas', ventas, Icons.attach_money),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<int>> _fetchSellerStats() async {
    if (_store == null) return [0, 0, 0];
    final productos =
        (await FirestoreService.getProductsByStore(_store!.id)).length;
    final pedidos = (await FirestoreService.getOrdersByStore(_store!.id)).length;
    final ventas = (await FirestoreService.getOrdersByStore(_store!.id))
        .fold<int>(0, (sum, order) => sum + order.totalAmount.toInt());
    return [productos, pedidos, ventas];
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.deepPurple),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  'Agregar Producto',
                  Icons.add,
                  Colors.green,
                  () {
                    Navigator.pushNamed(context, '/products');
                  },
                ),
                _buildActionCard(
                  context,
                  'Ver Pedidos',
                  Icons.list_alt,
                  Colors.blue,
                  () {
                    Navigator.pushNamed(context, '/orders');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    // This is a test comment to check if changes are being applied.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(158, 158, 158, 0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
