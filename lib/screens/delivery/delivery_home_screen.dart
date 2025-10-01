// lib/screens/delivery/delivery_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_market/models/order_model.dart';
import 'package:urban_market/providers/auth_provider.dart';
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
    // Llama al provider para que cargue los pedidos relevantes para el repartidor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).listenToOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Repartidor'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          // Usamos el getter que creamos en el OrderProvider.
          final deliveryOrders = orderProvider.inProcessOrders;

          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (deliveryOrders.isEmpty) {
            return const Center(
              child: Text('No hay pedidos asignados para entrega'),
            );
          }

          return ListView.builder(
            itemCount: deliveryOrders.length,
            itemBuilder: (context, index) {
              final order = deliveryOrders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderHeader(order),
                      const Divider(height: 24),
                      _buildOrderInfo('Cliente:', order.userName),
                      _buildOrderInfo('Teléfono:', order.userPhone),
                      _buildOrderInfo('Tienda:', order.storeName),
                      _buildOrderInfo('Dirección:', order.deliveryAddress),
                      const SizedBox(height: 8),
                      Text(
                        'Total: Bs. ${order.total.toStringAsFixed(2)}', // Símbolo de moneda cambiado
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButtons(context, order, orderProvider),
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

  // --- Widgets Auxiliares para una UI más limpia ---

  Widget _buildOrderHeader(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Pedido #${order.id.substring(0, 6)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _getStatusColor(order.status),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            _getStatusText(order.status),
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14),
          children: [
            TextSpan(
                text: label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, OrderModel order, OrderProvider orderProvider) {
    // Muestra diferentes botones según el estado actual del pedido
    if (order.status == OrderStatus.inProgress) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.motorcycle),
          label: const Text('RECOGER PEDIDO'),
          onPressed: () {
            orderProvider.updateOrderStatus(
                order.id, OrderStatus.outForDelivery);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    } else if (order.status == OrderStatus.outForDelivery) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('MARCAR COMO ENTREGADO'),
          onPressed: () {
            orderProvider.updateOrderStatus(order.id, OrderStatus.delivered);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    }
    // Si el estado es otro (entregado, cancelado, etc.), no se muestra ningún botón de acción.
    return const SizedBox.shrink();
  }

  Widget _buildDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
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
                  'Repartidor',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              // Limpiamos los listeners antes de salir
              Provider.of<OrderProvider>(context, listen: false)
                  .clearListeners();
              authProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.grey;
      case OrderStatus.confirmed:
        return Colors.orange; // Listo para recoger
      case OrderStatus.inProgress:
        return Colors.blueAccent; // Asignado
      case OrderStatus.outForDelivery:
        return Colors.teal; // En camino
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
      case OrderStatus.inProgress:
        return 'Por Recoger';
      case OrderStatus.outForDelivery:
        return 'En Camino';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}
