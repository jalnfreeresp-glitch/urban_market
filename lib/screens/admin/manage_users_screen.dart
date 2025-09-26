// lib/screens/admin/manage_users_screen.dart

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:urban_market/models/user_model.dart';
import 'package:urban_market/services/firestore_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  Future<void> _callCloudFunction({
    required BuildContext dialogContext,
    required GlobalKey<FormState> formKey,
    required Future<void> Function() function,
    required Function(bool) setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    try {
      await function();

      if (!dialogContext.mounted) return;
      Navigator.of(dialogContext).pop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Operación realizada con éxito'),
            backgroundColor: Colors.green),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!dialogContext.mounted) return;
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(
            content: Text('Error: ${e.message}'), backgroundColor: Colors.red),
      );
    } finally {
      setLoading(false);
    }
  }

  void _showCreateUserDialog() {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'customer';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Crear Nuevo Usuario'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty || !v.contains('@')
                          ? 'Email inválido'
                          : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration:
                          const InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                      validator: (v) =>
                          v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: ['customer', 'seller', 'delivery', 'admin']
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(_getRoleName(role)),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => selectedRole = value!),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        _callCloudFunction(
                          dialogContext: dialogContext,
                          formKey: formKey,
                          setLoading: (val) =>
                              setDialogState(() => isLoading = val),
                          function: () async {
                            final callable = FirebaseFunctions.instance
                                .httpsCallable('createUser');
                            await callable.call(<String, dynamic>{
                              'email': emailController.text.trim(),
                              'password': passwordController.text,
                              'name': nameController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'role': selectedRole,
                            });
                          },
                        );
                      },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Crear'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditUserDialog(User user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    String selectedRole = user.role;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Editar Usuario'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Nombre')),
                    TextFormField(
                        controller: phoneController,
                        decoration:
                            const InputDecoration(labelText: 'Teléfono')),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: ['customer', 'seller', 'delivery', 'admin']
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(_getRoleName(role)),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => selectedRole = value!),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        _callCloudFunction(
                          dialogContext: dialogContext,
                          formKey: formKey,
                          setLoading: (val) =>
                              setDialogState(() => isLoading = val),
                          function: () async {
                            final callable = FirebaseFunctions.instance
                                .httpsCallable('updateUser');
                            await callable.call(<String, dynamic>{
                              'uid': user.id,
                              'name': nameController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'role': selectedRole,
                            });
                          },
                        );
                      },
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateUserStatus(String uid, bool newStatus) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('setUserActiveStatus');
      await callable.call(<String, dynamic>{
        'uid': uid,
        'isActive': newStatus,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Estado actualizado'), backgroundColor: Colors.green),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${e.message}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Usuarios'),
      ),
      body: StreamBuilder<List<User>>(
        stream: FirestoreService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron usuarios.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                        user.name.isNotEmpty ? user.name.substring(0, 1) : 'U'),
                  ),
                  title: Text(user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('${user.email}\nRol: ${_getRoleName(user.role)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditUserDialog(user),
                      ),
                      Switch(
                        value: user.isActive,
                        onChanged: (newValue) =>
                            _updateUserStatus(user.id, newValue),
                        activeThumbColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateUserDialog,
        child: const Icon(Icons.add),
      ),
    );
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
        return 'Repartidor';
      default:
        return role;
    }
  }
}
