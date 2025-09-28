import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/user_model.dart' as um;
// Se corrige la ruta de importación del AuthProvider.
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/services/firestore_service.dart';

class ManageUsersScreen extends StatefulWidget {
  static const routeName = '/admin-manage-users';

  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showUserDialog({um.UserModel? user}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);
    final phoneController = TextEditingController(text: user?.phone);
    final passwordController = TextEditingController();
    final storeIdController = TextEditingController(text: user?.storeId);
    String selectedRole = user?.role ?? 'Cliente';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(user == null ? 'Añadir Usuario' : 'Editar Usuario'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo requerido' : null,
                    ),
                    if (user == null)
                      TextFormField(
                        controller: passwordController,
                        decoration:
                            const InputDecoration(labelText: 'Contraseña'),
                        obscureText: true,
                        validator: (value) =>
                            value!.isEmpty ? 'Campo requerido' : null,
                      ),
                    DropdownButtonFormField<String>(
                      // Se corrige el parámetro deprecado 'value' por 'initialValue'.
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items:
                          ['Cliente', 'Vendedor', 'Administrador', 'Repartidor']
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ))
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    if (selectedRole == 'Vendedor')
                      TextFormField(
                        controller: storeIdController,
                        decoration:
                            const InputDecoration(labelText: 'ID de la Tienda'),
                        validator: (value) =>
                            value!.isEmpty ? 'Campo requerido' : null,
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final authProvider = context.read<AuthProvider>();
                    try {
                      if (user == null) {
                        await authProvider.signup(
                          email: emailController.text,
                          password: passwordController.text,
                          name: nameController.text,
                          phone: phoneController.text,
                          role: selectedRole,
                          address: '', // Address can be added later by the user
                        );
                      } else {
                        final updatedUser = user.copyWith(
                            name: nameController.text,
                            email: emailController.text,
                            phone: phoneController.text,
                            role: selectedRole,
                            storeId: selectedRole == 'Vendedor'
                                ? storeIdController.text
                                : null);
                        await _firestoreService.updateUser(updatedUser);
                      }
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Usuarios'),
      ),
      body: StreamBuilder<List<um.UserModel>>(
        stream: _firestoreService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          final users = snapshot.data!;
          final groupedUsers = groupBy(users, (um.UserModel user) => user.role);

          return ListView.builder(
            itemCount: groupedUsers.keys.length,
            itemBuilder: (context, index) {
              final role = groupedUsers.keys.elementAt(index);
              final usersInRole = groupedUsers[role]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    child: Text(
                      '$role (${usersInRole.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  // Se elimina el '.toList()' innecesario.
                  ...usersInRole.map((user) => _buildUserCard(user)),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserCard(um.UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple[100],
          child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
        ),
        title: Text(user.name,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey[600]),
              onPressed: () => _showUserDialog(user: user),
            ),
            Switch(
              value: user.isActive,
              onChanged: (bool newValue) {
                final updatedUser = user.copyWith(isActive: newValue);
                _firestoreService.updateUser(updatedUser);
              },
              activeTrackColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
