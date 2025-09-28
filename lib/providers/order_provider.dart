import 'dart:async';
import 'package:flutter/foundation.dart';
// Se añaden alias para consistencia
import 'package:urban_market/models/order_model.dart' as om;
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/services/firestore_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthProvider? _authProvider; // Para obtener el usuario actual

  StreamSubscription<List<om.OrderModel>>? _ordersSubscription;
  List<om.OrderModel> _orders = [];
  List<om.OrderModel> _inProcessOrders = [];
  bool _isLoading = false;

  // --- Getters ---
  List<om.OrderModel> get orders => _orders;
  List<om.OrderModel> get inProcessOrders => _inProcessOrders;
  bool get isLoading => _isLoading;

  OrderProvider(this._authProvider) {
    // Si el usuario ya está logueado al iniciar el provider, se inicia la escucha.
    if (_authProvider?.isAuth ?? false) {
      listenToOrders();
    }
  }

  void listenToOrders({String? userId, String? role}) {
    final user = _authProvider?.user;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    Stream<List<om.OrderModel>>? ordersStream;
    final effectiveRole = role ?? user.role;
    final effectiveUserId = userId ?? user.id;

    switch (effectiveRole) {
      case 'Cliente':
        ordersStream = _firestoreService.getOrdersByUserStream(effectiveUserId);
        break;
      case 'Vendedor':
        if (user.storeId != null) {
          ordersStream =
              _firestoreService.getOrdersByStoreStream(user.storeId!);
        }
        break;
      case 'Repartidor':
        ordersStream =
            _firestoreService.getOrdersByDeliveryPersonStream(effectiveUserId);
        break;
      case 'Administrador':
        ordersStream = _firestoreService.getAllOrdersStream();
        break;
    }

    _ordersSubscription?.cancel(); // Cancela la suscripción anterior
    if (ordersStream != null) {
      _ordersSubscription = ordersStream.listen((ordersData) {
        _orders = ordersData;
        _isLoading = false;
        notifyListeners();
      }, onError: (error) {
        debugPrint("Error listening to orders: $error");
        _isLoading = false;
        notifyListeners();
      });
    } else {
      _isLoading = false;
      _orders = [];
      notifyListeners();
    }
  }

  void loadInProcessOrders() {
    _isLoading = true;
    notifyListeners();
    _firestoreService.getOrdersByStatusStream(om.OrderStatus.inProgress).listen((ordersData) {
      _inProcessOrders = ordersData;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint("Error listening to in process orders: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createOrder(om.OrderModel order) async {
    try {
      await _firestoreService.createOrder(order);
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(
      String orderId, om.OrderStatus newStatus) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, newStatus);
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}