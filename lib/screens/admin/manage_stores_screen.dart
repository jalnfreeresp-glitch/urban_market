// lib/screens/admin/manage_stores_screen.dart (actualizado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/store_model.dart';
import 'package:urban_market/models/user_model.dart' as user_model;
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/services/firestore_service.dart';

class ManageStoresScreen extends StatefulWidget {
  static const routeName = '/admin-manage-stores';

  const ManageStoresScreen({super.key});

  @override
  State<ManageStoresScreen> createState() => _ManageStoresScreenState();
}

class _ManageStoresScreenState extends State<ManageStoresScreen> {
  void _showStoreDialog({Store? store}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: store?.name);
    final descriptionController =
        TextEditingController(text: store?.description);
    final addressController = TextEditingController(text: store?.address);
    final phoneController = TextEditingController(text: store?.phone);
    final categoryController = TextEditingController(text: store?.category);
    final openingTimeController =
        TextEditingController(text: store?.openingTime);
    final closingTimeController =
        TextEditingController(text: store?.closingTime);
    String? selectedOwnerId = store?.ownerId;

    final sellers = await FirestoreService.getSellers();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(store == null ? 'Añadir Tienda' : 'Editar Tienda'),
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
                  DropdownButtonFormField<String>(
                    initialValue: selectedOwnerId,
                    decoration:
                        const InputDecoration(labelText: 'Dueño de la tienda'),
                    items: sellers.map((user_model.User seller) {
                      return DropdownMenuItem<String>(
                        value: seller.id,
                        child: Text(seller.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedOwnerId = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Campo requerido' : null,
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
                  final newStore = Store(
                    id: store?.id ?? '',
                    name: nameController.text,
                    description: descriptionController.text,
                    address: addressController.text,
                    phone: phoneController.text,
                    category: categoryController.text,
                    openingTime: openingTimeController.text,
                    closingTime: closingTimeController.text,
                    ownerId: selectedOwnerId!,
                    imageUrl: store?.imageUrl ?? '',
                    rating: store?.rating ?? 0,
                    totalReviews: store?.totalReviews ?? 0,
                    isActive: store?.isActive ?? true,
                    isOpen: store?.isOpen ?? false,
                  );

                  if (store == null) {
                    await FirestoreService.createStore(newStore);
                  } else {
                    await FirestoreService.updateStore(newStore);
                  }

                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  setState(() {});
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
                              onPressed: () => _showStoreDialog(store: store),
                            ),
                            Tooltip(
                              message: store.isActive
                                  ? 'Deshabilitar tienda'
                                  : 'Habilitar tienda',
                              child: IconButton(
                                icon: Icon(
                                  store.isActive
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: store.isActive
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                onPressed: () async {
                                  final updatedStore = store.copyWith(
                                    isActive: !store.isActive,
                                  );
                                  await FirestoreService.updateStore(
                                      updatedStore);
                                  setState(() {});
                                },
                              ),
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
        onPressed: () => _showStoreDialog(),
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
