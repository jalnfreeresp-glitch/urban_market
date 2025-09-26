import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos un Consumer para que la pantalla se redibuje si el carrito cambia.
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Carrito'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: cart.items.isEmpty
              // Si el carrito está vacío, muestra un mensaje.
              ? const Center(
                  child: Text(
                    'Tu carrito está vacío.',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                )
              // Si no, muestra la lista de productos y el total.
              : Column(
                  children: [
                    // La lista de productos ocupará el espacio disponible.
                    Expanded(
                      child: ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final product = cart.items[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(product.imageUrl),
                            ),
                            title: Text(product.name),
                            subtitle:
                                Text('\$${product.price.toStringAsFixed(2)}'),
                            // Botón para eliminar el producto.
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_shopping_cart,
                                  color: Colors.red),
                              onPressed: () {
                                cart.remove(product);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // Tarjeta con el resumen del total.
                    Card(
                      margin: const EdgeInsets.all(15),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Chip(
                              label: Text(
                                '\$${cart.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botón de Pagar.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Lógica de pago futura
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            'PAGAR',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
