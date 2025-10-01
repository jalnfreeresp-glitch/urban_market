import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/product_model.dart';
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/providers/product_provider.dart';
import 'package:urban_market/services/storage_service.dart';

class AddEditProductScreen extends StatefulWidget {
  static const routeName = '/add-edit-product';
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  final _logger = Logger();

  // Form fields
  late String _name;
  late String _description;
  late double _price;
  late int _stock;
  late String _categoriesString;

  // Image handling
  String? _imageUrl;
  File? _imageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _description = widget.product?.description ?? '';
    _price = widget.product?.price ?? 0.0;
    _imageUrl = widget.product?.imageUrl;
    _stock = widget.product?.stock ?? 0;
    _categoriesString = widget.product?.categories.join(', ') ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isUploading = true;
      });

      try {
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user!;
        final storeId = user.storeId!;

        String? finalImageUrl = _imageUrl;
        final productId = widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

        // If a new image was selected, upload it
        if (_imageFile != null) {
          finalImageUrl = await _storageService.uploadProductImage(
            _imageFile!,
            productId,
          );
        }

        // Get store name automatically
        String storeName = 'Nombre no encontrado';
        final sellerStore = productProvider.stores.where((s) => s.id == storeId);
        if (sellerStore.isNotEmpty) {
          storeName = sellerStore.first.name;
        }

        // Process categories string into a list
        final List<String> categoriesList = _categoriesString
            .split(',')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty)
            .toList();

        final newProduct = ProductModel(
          id: productId,
          name: _name,
          description: _description,
          price: _price,
          imageUrl: finalImageUrl ?? '',
          storeId: storeId,
          storeName: storeName,
          stock: _stock,
          categories: categoriesList,
        );

        if (widget.product == null) {
          await productProvider.addProduct(newProduct);
        } else {
          await productProvider.updateProduct(newProduct);
        }

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Handle errors, maybe show a dialog
        _logger.e('Error saving product: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
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
          if (!_isUploading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveForm,
            ),
        ],
      ),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Guardando producto...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 24),
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
                      initialValue: _stock.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _categoriesString,
                      decoration: const InputDecoration(
                        labelText: 'Categorías (separadas por coma)',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onSaved: (value) {
                        _categoriesString = value ?? '';
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imageFile != null
              ? Image.file(_imageFile!, fit: BoxFit.cover)
              : (_imageUrl != null && _imageUrl!.isNotEmpty)
                  ? Image.network(_imageUrl!, fit: BoxFit.cover)
                  : const Center(
                      child: Text(
                        'No hay imagen seleccionada.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.image),
          label: const Text('Seleccionar Imagen'),
          onPressed: _pickImage,
        ),
      ],
    );
  }
}