// lib/screens/seller/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/order_model.dart';
import 'package:urban_market/providers/order_provider.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text('No tienes pedidos aún'),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pedido #${order.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(order.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tienda: ${order.storeName}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Fecha: ${order.orderDate.toString().split('.')[0]}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (order.paymentReference != null)
                          Text(
                            'Ref. de pago: ${order.paymentReference}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Total: S/. ${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Productos:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...order.items
                            .map((item) => ListTile(
                                  leading: const Icon(Icons.shopping_basket),
                                  title: Text(item.productName),
                                  subtitle: Text('Cantidad: ${item.quantity}'),
                                  trailing: Text(
                                      'S/. ${(item.price * item.quantity).toStringAsFixed(2)}'),
                                ))
                            .toList(),
                        if (order.deliveryPersonName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Entregado por: ${order.deliveryPersonName}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        if (order.status == OrderStatus.pendientePago)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                orderProvider.updateOrderStatus(
                                    order.id, OrderStatus.enProceso);
                              },
                              child: const Text('Aceptar Pedido'),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendientePago:
        return Colors.orange;
      case OrderStatus.enProceso:
        return Colors.blue;
      case OrderStatus.enCamino:
        return Colors.teal;
      case OrderStatus.entregado:
        return Colors.green;
      case OrderStatus.cancelado:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendientePago:
        return 'Pendiente de Pago';
      case OrderStatus.enProceso:
        return 'En Proceso';
      case OrderStatus.enCamino:
        return 'En Camino';
      case OrderStatus.entregado:
        return 'Entregado';
      case OrderStatus.cancelado:
        return 'Cancelado';
    }
  }
}
