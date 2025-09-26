// lib/screens/admin/manage_users_screen.dart (actualizado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/user_model.dart';
import 'package:urban_market/providers/auth_provider.dart';

class ManageUsersScreen extends StatefulWidget {
  static const routeName = '/admin-manage-users';

  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Usuarios'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context, authProvider),
      body: ListView.builder(
        itemCount: _getUsers().length,
        itemBuilder: (context, index) {
          final user = _getUsers()[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Text(
                  user.name.substring(0, 1),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.email),
                  Text('Rol: ${_getRoleName(user.role)}'),
                  Text('Creado: ${user.createdAt.toString().split(' ')[0]}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Editar usuario
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      user.isActive ? Icons.visibility : Icons.visibility_off,
                      color: user.isActive ? Colors.green : Colors.red,
                    ),
                    onPressed: () {
                      // Activar/desactivar usuario
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(user.isActive
                              ? 'Usuario desactivado'
                              : 'Usuario activado'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<User> _getUsers() {
    // Lista de ejemplo de usuarios
    return [
      User(
        id: 'u1',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        phone: '987654321',
        role: 'seller',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        id: 'u2',
        name: 'María García',
        email: 'maria@example.com',
        phone: '987654322',
        role: 'customer',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      User(
        id: 'u3',
        name: 'Carlos López',
        email: 'carlos@example.com',
        phone: '987654323',
        role: 'delivery',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'seller':
        return 'Vendedor';
      case 'customer':
        return 'Cliente';
      case 'delivery':
        return 'Delivery';
      default:
        return role;
    }
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
              Navigator.pushNamed(context, '/admin-manage-stores');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Gestionar Usuarios'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/admin-manage-users');
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
