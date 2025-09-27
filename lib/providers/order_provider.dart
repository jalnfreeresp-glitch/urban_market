import 'package:collection/collection.dart'; // Importar collection
import 'package:flutter/foundation.dart';
import 'package:urban_market/models/order_model.dart';
import 'package:urban_market/services/firestore_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  List<OrderModel> _pendingOrders = [];
  List<OrderModel> _inProcessOrders = [];

  List<OrderModel> get orders => _orders;
  List<OrderModel> get pendingOrders => _pendingOrders;
  List<OrderModel> get inProcessOrders => _inProcessOrders;

  Future<void> loadOrders(String userId, String role) async {
    try {
      List<OrderModel> orders;
      if (role == 'Cliente') {
        orders = await FirestoreService.getOrdersByUser(userId);
      } else if (role == 'Vendedor') {
        orders = await FirestoreService.getOrdersByStore(userId);
      } else if (role == 'Repartidor') {
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

  Future<void> loadInProcessOrders() async {
    try {
      final orders = await FirestoreService.getInProcessOrders();
      _inProcessOrders = orders;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading in process orders: $e');
    }
  }

  Future<void> createOrder(OrderModel order) async {
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

  OrderModel? getOrderById(String orderId) {
    // Usar firstWhereOrNull para evitar el error de tipo
    return _orders.firstWhereOrNull((order) => order.id == orderId);
  }
}
