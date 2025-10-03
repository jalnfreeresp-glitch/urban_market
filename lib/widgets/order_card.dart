import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/order_model.dart' as om;
import 'package:urban_market/providers/order_provider.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final om.OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        title: Text(
          'Pedido #${order.id.substring(0, 6)}...',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${order.userName}'),
            Text('Tienda: ${order.storeName}'),
            Text('Total: \$ ${order.total.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Chip(
          label: Text(
            order.status.name,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: order.status.color,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Cambio de estado:'),
                DropdownButton<om.OrderStatus>(
                  value: order.status,
                  items: om.OrderStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name),
                    );
                  }).toList(),
                  onChanged: (newStatus) async {
                    if (newStatus != null && newStatus != order.status) {
                      try {
                        await Provider.of<OrderProvider>(context, listen: false)
                            .updateOrderStatus(order.id, newStatus);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Estado actualizado a: ${newStatus.name}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al actualizar estado: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
