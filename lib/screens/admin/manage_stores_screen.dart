// lib/screens/admin/manage_stores_screen.dart (actualizado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/store_model.dart';
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/services/firestore_service.dart';

class ManageStoresScreen extends StatefulWidget {
  static const routeName = '/admin-manage-stores';

  const ManageStoresScreen({super.key});

  @override
  State<ManageStoresScreen> createState() => _ManageStoresScreenState();
}

class _ManageStoresScreenState extends State<ManageStoresScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Tiendas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context, authProvider),
      body: FutureBuilder<List<Store>>(
        future: FirestoreService.getAllStores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final stores = snapshot.data ?? [];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text('Total de tiendas: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(stores.length.toString()),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: store.imageUrl.isNotEmpty
                              ? Image.network(
                                  store.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.store),
                                    );
                                  },
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.store),
                                ),
                        ),
                        title: Text(store.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${store.category} - ${store.address}',
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                store.isActive
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color:
                                    store.isActive ? Colors.green : Colors.red,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Crear nueva tienda
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
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
                  'Administrador',
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
            title: const Text('Gestionar Tiendas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/admin-manage-stores');
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
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
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
}
