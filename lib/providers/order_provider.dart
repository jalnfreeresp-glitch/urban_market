// lib/providers/order_provider.dart (actualizado)
import 'package:collection/collection.dart'; // Importar collection
import 'package:flutter/foundation.dart';
import 'package:urban_market/models/order_model.dart';
import 'package:urban_market/services/firestore_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  List<Order> _pendingOrders = [];

  List<Order> get orders => _orders;
  List<Order> get pendingOrders => _pendingOrders;

  Future<void> loadOrders(String userId, String role) async {
    try {
      List<Order> orders;
      if (role == 'customer') {
        orders = await FirestoreService.getOrdersByUser(userId);
      } else if (role == 'seller') {
        orders = await FirestoreService.getOrdersByStore(userId);
      } else if (role == 'delivery') {
        orders = await FirestoreService.getOrdersByDeliveryPerson(userId);
      } else {
        // Para admin, obtener todos los pedidos
        orders = await FirestoreService.getAllOrders();
      }
      _orders = orders;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
  }

  Future<void> loadPendingOrders() async {
    try {
      final orders = await FirestoreService.getPendingOrders();
      _pendingOrders = orders;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pending orders: $e');
    }
  }

  Future<void> createOrder(Order order) async {
    try {
      await FirestoreService.createOrder(order);
      _orders.insert(0, order);
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await FirestoreService.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  Order? getOrderById(String orderId) {
    // Usar firstWhereOrNull para evitar el error de tipo
    return _orders.firstWhereOrNull((order) => order.id == orderId);
  }
}

extension OrderExtension on Order {
  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? storeId,
    String? storeName,
    List<OrderItem>? items,
    double? totalAmount,
    DateTime? orderDate,
    OrderStatus? status,
    String? deliveryPersonId,
    String? deliveryPersonName,
    DateTime? deliveryTime,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
      deliveryPersonName: deliveryPersonName ?? this.deliveryPersonName,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      notes: notes ?? this.notes,
    );
  }
}
