// lib/screens/delivery/delivery_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/order_model.dart';
import 'package:urban_market/providers/order_provider.dart';

class DeliveryHomeScreen extends StatelessWidget {
  static const routeName = '/delivery';

  const DeliveryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Delivery'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final pendingOrders = orderProvider.pendingOrders;

          if (pendingOrders.isEmpty) {
            return const Center(
              child: Text('No hay pedidos pendientes de entrega'),
            );
          }

          return ListView.builder(
            itemCount: pendingOrders.length,
            itemBuilder: (context, index) {
              final order = pendingOrders[index];
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
                        'Cliente: ${order.customerName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Tienda: ${order.storeName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Dirección: ${order.customerAddress}',
                        style: const TextStyle(fontSize: 14),
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Aceptar el pedido
                                orderProvider.updateOrderStatus(
                                    order.id, OrderStatus.preparing);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Aceptar'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Rechazar el pedido
                                orderProvider.updateOrderStatus(
                                    order.id, OrderStatus.cancelled);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Rechazar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.yellow[700]!;
      case OrderStatus.ready:
        return Colors.purple;
      case OrderStatus.pickedUp:
        return Colors.indigo;
      case OrderStatus.delivering:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'En preparación';
      case OrderStatus.ready:
        return 'Listo';
      case OrderStatus.pickedUp:
        return 'Recogido';
      case OrderStatus.delivering:
        return 'En camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}
