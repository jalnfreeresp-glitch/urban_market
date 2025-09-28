import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// Se añaden alias para consistencia
import 'package:urban_market/models/order_model.dart' as om;
import 'package:urban_market/models/store_model.dart' as sm;
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/providers/cart_provider.dart';
import 'package:urban_market/providers/order_provider.dart';
import 'package:urban_market/services/firestore_service.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  // Se usa el alias 'sm' para el tipo de 'store'.
  void _showPaymentDialog(BuildContext context, sm.StoreModel store) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Datos de Pagomovil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentDetailRow(ctx, 'Teléfono:', store.paymentPhoneNumber),
            _buildPaymentDetailRow(ctx, 'Banco:', store.paymentBankName),
            _buildPaymentDetailRow(ctx, 'Cédula:', store.paymentNationalId),
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

  Widget _buildPaymentDetailRow(
      BuildContext context, String label, String value) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copiado al portapapeles'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // Se usa el alias 'sm' para el tipo de 'store'.
  void _showReferenceDialog(BuildContext context, sm.StoreModel store) {
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

                // Se resuelve el TODO de la tarifa de envío con un valor fijo.
                const deliveryFee = 5.00;
                final total = cart.totalAmount + deliveryFee;

                // Se utiliza el constructor de OrderModel con los nombres de campo correctos.
                final newOrder = om.OrderModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  userId: auth.user!.id,
                  userName: auth.user!.name,
                  userPhone: auth.user!.phone,
                  deliveryAddress: auth.user!.address ?? 'No especificada',
                  storeId: store.id,
                  storeName: store.name,
                  items: cart.items.values.toList(),
                  subtotal: cart.totalAmount,
                  deliveryFee: deliveryFee,
                  total: total,
                  status: om.OrderStatus.pending,
                  createdAt: DateTime.now(),
                  paymentTransactionId: referenceController.text,
                );

                orderProvider.createOrder(newOrder);
                cart.clear();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pedido realizado con éxito!'),
                    backgroundColor: Colors.green,
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
    final firestoreService = FirestoreService();
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Carrito'),
          ),
          body: cart.items.isEmpty
              ? const Center(
                  child: Text(
                    'Tu carrito está vacío.',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
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
                    Card(
                      margin: const EdgeInsets.all(15),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (cart.storeId != null) {
                              // Se llama al método getStore que ahora sí existe.
                              final store = await firestoreService
                                  .getStore(cart.storeId!);
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
                          child: const Text('PAGAR',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
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
