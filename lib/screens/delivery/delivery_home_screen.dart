// lib/screens/delivery/delivery_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/order_model.dart';
import 'package:urban_market/providers/order_provider.dart';

class DeliveryHomeScreen extends StatefulWidget {
  static const routeName = '/delivery';

  const DeliveryHomeScreen({super.key});

  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Using addPostFrameCallback to avoid calling provider before the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).loadInProcessOrders();
    });
  }

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
          final inProcessOrders = orderProvider.inProcessOrders;

          if (inProcessOrders.isEmpty) {
            return const Center(
              child: Text('No hay pedidos pendientes de entrega'),
            );
          }

          return ListView.builder(
            itemCount: inProcessOrders.length,
            itemBuilder: (context, index) {
              final order = inProcessOrders[index];
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
                                    order.id, OrderStatus.enCamino);
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
                                    order.id, OrderStatus.cancelado);
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
