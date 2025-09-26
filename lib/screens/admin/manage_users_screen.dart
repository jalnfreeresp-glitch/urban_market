import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/user_model.dart' as user_model;
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/services/firestore_service.dart';

class ManageUsersScreen extends StatefulWidget {
  static const routeName = '/admin-manage-users';

  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  void _showUserDialog({user_model.User? user}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);
    final phoneController = TextEditingController(text: user?.phone);
    final passwordController = TextEditingController();
    String selectedRole = user?.role ?? 'customer';

    showDialog(
      context: context,
      builder: (context) {
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
                    initialValue: selectedRole,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: ['customer', 'seller', 'admin', 'delivery']
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
                        emailController.text,
                        passwordController.text,
                        nameController.text,
                        phoneController.text,
                        selectedRole,
                        '', // Address is not needed here
                      );
                    } else {
                      final updatedUser = user.copyWith(
                        name: nameController.text,
                        email: emailController.text,
                        phone: phoneController.text,
                        role: selectedRole,
                      );
                      await FirestoreService.updateUser(updatedUser);
                    }
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    setState(() {});
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Usuarios'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<user_model.User>>(
        future: FirestoreService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(user.role),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showUserDialog(user: user),
                    ),
                  ],
                ),
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
}
