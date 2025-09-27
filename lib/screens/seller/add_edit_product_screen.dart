import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/product_model.dart';
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/providers/product_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  static const routeName = '/add-edit-product';
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _price = 0.0;
  late String _imageUrl;
  late String _storeName;
  late int _stock = 0;
  late List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _description = widget.product?.description ?? '';
    _price = widget.product?.price ?? 0.0;
    _imageUrl = widget.product?.imageUrl ?? '';
    _storeName = widget.product?.storeName ?? '';
    _stock = widget.product?.stock ?? 0;
    _categories = widget.product?.categories ?? [];
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      final newProduct = ProductModel(
        id: widget.product?.id ?? DateTime.now().toString(),
        name: _name,
        description: _description,
        price: _price,
        imageUrl: _imageUrl,
        storeId: user!.storeId!,
        storeName: _storeName,
        stock: _stock,
        categories: _categories,
      );

      if (widget.product == null) {
        productProvider.addProduct(newProduct);
      } else {
        productProvider.updateProduct(newProduct);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.product == null ? 'Agregar Producto' : 'Editar Producto'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _name = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                onSaved: (value) {
                  _description = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _price.toString(),
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _price = double.parse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un precio.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido.';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Por favor ingrese un número mayor que cero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _imageUrl,
                decoration: const InputDecoration(
                  labelText: 'URL de Imagen',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _imageUrl = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una URL de imagen.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _storeName,
                decoration: const InputDecoration(
                  labelText: 'Nombre de Tienda',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _storeName = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre de la tienda.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _stock.toString(),
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSaved: (value) {
                  _stock = int.parse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la cantidad en stock.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido.';
                  }
                  if (int.parse(value) < 0) {
                    return 'La cantidad no puede ser negativa.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}