// lib/screens/admin/manage_orders_screen.dart (actualizado)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/order_model.dart';
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/providers/order_provider.dart';

class ManageOrdersScreen extends StatefulWidget {
  static const routeName = '/admin-manage-orders';

  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Pedidos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context, authProvider),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          // Aquí usaríamos orderProvider.orders
          // Por ahora usamos una lista de ejemplo
          final orders = [
            Order(
              id: 'o1',
              customerId: 'c1',
              customerName: 'Juan Pérez',
              customerPhone: '987654321',
              customerAddress: 'Calle Principal 123',
              storeId: 's1',
              storeName: 'Tienda de Comida',
              items: [
                OrderItem(
                  productId: 'p1',
                  productName: 'Tomates Frescos',
                  price: 2.50,
                  quantity: 2,
                  storeId: 's1',
                ),
              ],
              totalAmount: 7.50,
              orderDate: DateTime.now(),
              status: OrderStatus.confirmed,
            ),
            Order(
              id: 'o2',
              customerId: 'c2',
              customerName: 'María García',
              customerPhone: '987654322',
              customerAddress: 'Av. Central 456',
              storeId: 's2',
              storeName: 'Supermercado ABC',
              items: [
                OrderItem(
                  productId: 'p2',
                  productName: 'Pan Artesanal',
                  price: 3.00,
                  quantity: 1,
                  storeId: 's2',
                ),
              ],
              totalAmount: 12.00,
              orderDate: DateTime.now().subtract(const Duration(hours: 2)),
              status: OrderStatus.delivering,
            ),
          ];

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        'Total: S/. ${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Ver detalles del pedido
                              _showOrderDetails(context, order);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Detalles'),
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

  void _showOrderDetails(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Detalles del Pedido #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${order.customerName}'),
            Text('Teléfono: ${order.customerPhone}'),
            Text('Dirección: ${order.customerAddress}'),
            Text('Tienda: ${order.storeName}'),
            const SizedBox(height: 16),
            const Text('Productos:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items
                .map((item) => ListTile(
                      title: Text(item.productName),
                      subtitle: Text(
                          'Cantidad: ${item.quantity} x S/. ${item.price.toStringAsFixed(2)}'),
                      trailing: Text(
                          'S/. ${(item.price * item.quantity).toStringAsFixed(2)}'),
                    ))
                .toList(),
            const Divider(),
            Text('Total: S/. ${order.totalAmount.toStringAsFixed(2)}'),
            Text('Fecha: ${order.orderDate}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Urban Market',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Administrador',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Gestionar Tiendas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin-manage-stores');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Gestionar Usuarios'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin-manage-users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Gestionar Pedidos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/admin-manage-orders');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}
