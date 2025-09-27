import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/order_model.dart';
import 'package:urban_market/models/store_model.dart';
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/providers/cart_provider.dart';
import 'package:urban_market/providers/order_provider.dart';
import 'package:urban_market/services/firestore_service.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  void _showPaymentDialog(BuildContext context, StoreModel store) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Datos de Pagomovil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentDetailRow('Teléfono:', store.paymentPhoneNumber),
            _buildPaymentDetailRow('Banco:', store.paymentBankName),
            _buildPaymentDetailRow('Cédula:', store.paymentNationalId),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Ya realicé el pago'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _showReferenceDialog(context, store);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Text(value),
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showReferenceDialog(BuildContext context, StoreModel store) {
    final referenceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Número de Referencia'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: referenceController,
            decoration: const InputDecoration(labelText: 'Referencia'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el número de referencia';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Confirmar'),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final cart = Provider.of<CartProvider>(context, listen: false);
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final orderProvider =
                    Provider.of<OrderProvider>(context, listen: false);

                final newOrder = OrderModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  customerId: auth.user!.id,
                  customerName: auth.user!.name,
                  customerPhone: auth.user!.phone,
                  customerAddress: auth.user!.address ?? '',
                  storeId: store.id,
                  storeName: store.name,
                  items: cart.items.values
                      .map((cartItem) => OrderItemModel(
                            productId: cartItem.product.id,
                            productName: cartItem.product.name,
                            price: cartItem.product.price,
                            quantity: cartItem.quantity,
                            storeId: cartItem.product.storeId,
                          ))
                      .toList(),
                  totalAmount: cart.totalAmount,
                  orderDate: DateTime.now(),
                  status: OrderStatus.pendientePago,
                  paymentReference: referenceController.text,
                );

                orderProvider.createOrder(newOrder);
                cart.clear();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pedido realizado con éxito!'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

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
                          final cartItem = cart.items.values.toList()[index];
                          final product = cartItem.product;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(product.imageUrl),
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                                'S/. ${product.price.toStringAsFixed(2)} x ${cartItem.quantity}'),
                            // Botón para eliminar el producto.
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_shopping_cart,
                                  color: Colors.red),
                              onPressed: () {
                                cart.removeItem(product.id);
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
                                'S/. ${cart.totalAmount.toStringAsFixed(2)}',
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
                          onPressed: () async {
                            if (cart.storeId != null) {
                              final store = await FirestoreService.getStore(
                                  cart.storeId!);
                              if (store != null) {
                                if (!context.mounted) return;
                                _showPaymentDialog(context, store);
                              }
                            }
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
