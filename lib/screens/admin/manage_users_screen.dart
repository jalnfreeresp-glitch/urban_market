// lib/screens/admin/manage_users_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/store_model.dart';
import 'package:urban_market/models/user_model.dart' as um;
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/services/firestore_service.dart';
import 'package:urban_market/widgets/admin_drawer.dart';

class ManageUsersScreen extends StatefulWidget {
  static const routeName = '/admin-manage-users';

  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';
  String _selectedRoleFilter = 'Todos';

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
                    if (user != null && selectedRole == 'Vendedor')
                      TextFormField(
                        controller: storeIdController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'ID de Tienda Asignada',
                          hintText: 'Asignada desde la lista de usuarios',
                        ),
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
                          address: '',
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

  void _showCreateStoreDialog(um.UserModel seller) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final categoryController = TextEditingController();
    final openingTimeController = TextEditingController();
    final closingTimeController = TextEditingController();
    final paymentPhoneNumberController = TextEditingController();
    final paymentBankNameController = TextEditingController();
    final paymentNationalIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Crear tienda para ${seller.name}'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre de la tienda'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: openingTimeController,
                    decoration:
                        const InputDecoration(labelText: 'Hora de apertura'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: closingTimeController,
                    decoration:
                        const InputDecoration(labelText: 'Hora de cierre'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: paymentPhoneNumberController,
                    decoration: const InputDecoration(
                        labelText: 'Número de teléfono (Pagomovil)'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: paymentBankNameController,
                    decoration:
                        const InputDecoration(labelText: 'Banco (Pagomovil)'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: paymentNationalIdController,
                    decoration: const InputDecoration(
                        labelText: 'Cédula de Identidad (Pagomovil)'),
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
                  final newStoreRef =
                      FirebaseFirestore.instance.collection('stores').doc();

                  final newStore = StoreModel(
                    id: newStoreRef.id,
                    name: nameController.text,
                    description: descriptionController.text,
                    address: addressController.text,
                    phone: phoneController.text,
                    category: categoryController.text,
                    openingTime: openingTimeController.text,
                    closingTime: closingTimeController.text,
                    ownerId: seller.id,
                    imageUrl: '',
                    paymentPhoneNumber: paymentPhoneNumberController.text,
                    paymentBankName: paymentBankNameController.text,
                    paymentNationalId: paymentNationalIdController.text,
                  );

                  try {
                    await _firestoreService.createStoreForSeller(
                        newStore, seller.id);

                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Tienda creada y asignada a ${seller.name}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al crear la tienda: $e'),
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

  List<um.UserModel> _filterUsers(List<um.UserModel> users) {
    return users.where((user) {
      final matchesSearch =
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole =
          _selectedRoleFilter == 'Todos' || user.role == _selectedRoleFilter;
      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Gestionar Usuarios'),
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRoleFilter,
                  decoration:
                      const InputDecoration(labelText: 'Filtrar por rol'),
                  items: [
                    'Todos',
                    'Cliente',
                    'Vendedor',
                    'Administrador',
                    'Repartidor'
                  ]
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRoleFilter = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<um.UserModel>>(
              stream: _firestoreService.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No hay usuarios registrados.'));
                }

                final allUsers = snapshot.data!;
                final filteredUsers = _filterUsers(allUsers);
                final groupedUsers =
                    groupBy(filteredUsers, (um.UserModel user) => user.role);

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
                        ...usersInRole.map((user) => _buildUserCard(user)),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
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
            if (user.role == 'Vendedor' &&
                (user.storeId == null || user.storeId!.isEmpty))
              Tooltip(
                message: 'Crear tienda para este vendedor',
                child: IconButton(
                  icon: const Icon(Icons.add_business, color: Colors.green),
                  onPressed: () {
                    _showCreateStoreDialog(user);
                  },
                ),
              ),
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