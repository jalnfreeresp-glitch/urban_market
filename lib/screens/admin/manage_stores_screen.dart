import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/models/store_model.dart';
import 'package:urban_market/models/user_model.dart' as user_model;
import 'package:urban_market/services/firestore_service.dart';

class ManageStoresScreen extends StatefulWidget {
  static const routeName = '/admin-manage-stores';

  const ManageStoresScreen({super.key});

  @override
  State<ManageStoresScreen> createState() => _ManageStoresScreenState();
}

class _ManageStoresScreenState extends State<ManageStoresScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showStoreDialog({StoreModel? store}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: store?.name);
    final descriptionController =
        TextEditingController(text: store?.description);
    final addressController = TextEditingController(text: store?.address);
    final phoneController = TextEditingController(text: store?.phone);
    final openingTimeController =
        TextEditingController(text: store?.openingTime);
    final closingTimeController =
        TextEditingController(text: store?.closingTime);
    final deliveryFeeController =
        TextEditingController(text: store?.deliveryFee.toString());
    final paymentPhoneNumberController =
        TextEditingController(text: store?.paymentPhoneNumber);
    final paymentBankNameController =
        TextEditingController(text: store?.paymentBankName);
    final paymentNationalIdController =
        TextEditingController(text: store?.paymentNationalId);
    String? selectedOwnerId = store?.ownerId;

    String? selectedCategory = store?.category;
    final List<String> categories = [
      'Restaurantes',
      'Supermercados',
      'Electrónicos',
      'Ropa',
      'Hogar',
      'Bodega' // Added Bodega category
    ];

    if (selectedCategory != null && !categories.contains(selectedCategory)) {
      selectedCategory = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(store == null ? 'Añadir Tienda' : 'Editar Tienda'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
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
                        decoration:
                            const InputDecoration(labelText: 'Descripción'),
                        validator: (value) =>
                            value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration:
                            const InputDecoration(labelText: 'Dirección'),
                        validator: (value) =>
                            value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration:
                            const InputDecoration(labelText: 'Teléfono'),
                        validator: (value) =>
                            value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue:
                            selectedCategory, // Using value is correct here because it's inside a StatefulBuilder
                        decoration:
                            const InputDecoration(labelText: 'Categoría'),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Campo requerido' : null,
                      ),
                      TextFormField(
                        controller: openingTimeController,
                        decoration: const InputDecoration(
                            labelText: 'Hora de apertura'),
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
                        decoration: const InputDecoration(
                            labelText: 'Banco (Pagomovil)'),
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
                      StreamBuilder<List<user_model.UserModel>>(
                        stream: _firestoreService.getSellersStream(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final sellers = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            initialValue: selectedOwnerId,
                            decoration: const InputDecoration(
                                labelText: 'Dueño de la tienda'),
                            items: sellers.map((user_model.UserModel seller) {
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
                          );
                        },
                      ),
                    ],
                  );
                },
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
                  final newStore = StoreModel(
                    id: store?.id ?? '',
                    name: nameController.text,
                    description: descriptionController.text,
                    address: addressController.text,
                    phone: phoneController.text,
                    category: selectedCategory!,
                    openingTime: openingTimeController.text,
                    closingTime: closingTimeController.text,
                    deliveryFee: double.parse(deliveryFeeController.text),
                    ownerId: selectedOwnerId!,
                    imageUrl: store?.imageUrl ?? '',
                    rating: store?.rating ?? 0,
                    totalReviews: store?.totalReviews ?? 0,
                    isActive: store?.isActive ?? true,
                    isOpen: store?.isOpen ?? false,
                    paymentPhoneNumber: paymentPhoneNumberController.text,
                    paymentBankName: paymentBankNameController.text,
                    paymentNationalId: paymentNationalIdController.text,
                  );

                  if (store == null) {
                    await _firestoreService.createStore(newStore);
                  } else {
                    await _firestoreService.updateStore(newStore);
                  }

                  if (!context.mounted) return;
                  Navigator.of(context).pop();
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
        leading: const BackButton(),
        title: const Text('Gestionar Tiendas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context, authProvider),
      body: StreamBuilder<List<StoreModel>>(
        stream: _firestoreService.getStoresStream(),
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
                                  await _firestoreService
                                      .updateStore(updatedStore);
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
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
