import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/product_model.dart';
import 'package:urban_market/models/store_model.dart';
import 'package:urban_market/providers/cart_provider.dart';
import 'package:urban_market/providers/product_provider.dart';

class StoreProductsScreen extends StatefulWidget {
  static const routeName = '/store-products';

  final StoreModel store;

  const StoreProductsScreen({super.key, required this.store});

  @override
  State<StoreProductsScreen> createState() => _StoreProductsScreenState();
}

class _StoreProductsScreenState extends State<StoreProductsScreen> {
  @override
  void initState() {
    // Cargar productos de la tienda específica
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false)
          .filterProductsByStore(widget.store.id);
    });
    super.initState();
  }

  void _showAddToCartDialog(ProductModel product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final quantityController = TextEditingController(text: '1');
    int quantity = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(product.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Stock disponible: ${product.stock}'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                            quantityController.text = quantity.toString();
                          });
                        }
                      },
                    ),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: quantityController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final newQuantity = int.tryParse(value);
                          if (newQuantity != null &&
                              newQuantity > 0 &&
                              newQuantity <= product.stock) {
                            quantity = newQuantity;
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (quantity < product.stock) {
                          setState(() {
                            quantity++;
                            quantityController.text = quantity.toString();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Añadir al carrito'),
                onPressed: () {
                  final finalQuantity =
                      int.tryParse(quantityController.text) ?? 1;
                  if (finalQuantity > 0 && finalQuantity <= product.stock) {
                    cartProvider.addItem(product, quantity: finalQuantity);
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} añadido al carrito!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('La cantidad debe ser menor o igual al stock'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store.name),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProductProvider>(
        builder: (ctx, productProvider, child) {
          final products = productProvider.filteredProducts;

          if (products.isEmpty) {
            return const Center(
              child: Text('No hay productos disponibles en esta tienda'),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$ ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (product.stock > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${product.stock} disponibles',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        )
                      else
                        const Text(
                          'Agotado',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    _showAddToCartDialog(product);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/cart');
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
