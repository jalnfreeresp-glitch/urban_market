import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:urban_market/models/order_model.dart' as om;
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/services/firestore_service.dart';

// Helper class for Admin balances
class StoreBalance {
  final String storeId;
  final String storeName;
  final double total;

  StoreBalance(
      {required this.storeId, required this.storeName, required this.total});
}

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthProvider? _authProvider;

  // General state
  StreamSubscription<List<om.OrderModel>>? _ordersSubscription;
  List<om.OrderModel> _orders = [];
  bool _isLoading = false;

  // Seller balance state
  double _dailyBalance = 0.0;
  double _weeklyBalance = 0.0;
  double _monthlyBalance = 0.0;
  double _totalBalance = 0.0;
  StreamSubscription? _dailyBalanceSub,
      _weeklyBalanceSub,
      _monthlyBalanceSub,
      _totalBalanceSub;

  // Admin balance state
  double _platformTotalBalance = 0.0;
  List<StoreBalance> _sellerBalances = [];
  StreamSubscription? _adminBalancesSub;

  // --- Getters ---
  List<om.OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  // Seller getters
  double get dailyBalance => _dailyBalance;
  double get weeklyBalance => _weeklyBalance;
  double get monthlyBalance => _monthlyBalance;
  double get totalBalance => _totalBalance;
  // Admin getters
  double get platformTotalBalance => _platformTotalBalance;
  List<StoreBalance> get sellerBalances => _sellerBalances;

  // ✅ NUEVO GETTER PARA EL REPARTIDOR
  List<om.OrderModel> get inProcessOrders {
    // Filtra la lista principal para mostrar solo los pedidos relevantes para el repartidor
    return _orders.where((order) {
      return order.status == om.OrderStatus.inProgress ||
          order.status == om.OrderStatus.outForDelivery;
    }).toList();
  }

  OrderProvider(this._authProvider) {
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

    // Clear all listeners before setting up new ones
    clearListeners();

    switch (effectiveRole) {
      case 'Cliente':
        ordersStream = _firestoreService.getOrdersByUserStream(effectiveUserId);
        break;
      case 'Vendedor':
        if (user.storeId != null) {
          ordersStream =
              _firestoreService.getOrdersByStoreStream(user.storeId!);
          listenToSellerBalance(user.storeId!);
        }
        break;
      case 'Repartidor':
        // ✅ LÓGICA ACTUALIZADA PARA EL REPARTIDOR
        // Escucha los pedidos que están listos para ser recogidos
        ordersStream = _firestoreService
            .getOrdersByStatusStream(om.OrderStatus.inProgress);
        break;
      case 'Administrador':
        ordersStream = _firestoreService.getAllOrdersStream();
        listenToAdminBalances();
        break;
    }

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

  void listenToSellerBalance(String storeId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth =
        DateTime(now.year, now.month + 1, 0).add(const Duration(days: 1));
    final veryOldDate = DateTime(2000);

    _dailyBalanceSub = _firestoreService
        .getDeliveredOrdersByStoreStream(storeId, startOfDay, endOfDay)
        .listen((orders) {
      _dailyBalance = orders.fold(0.0, (sum, order) => sum + order.total);
      notifyListeners();
    });

    _weeklyBalanceSub = _firestoreService
        .getDeliveredOrdersByStoreStream(storeId, startOfWeek, endOfWeek)
        .listen((orders) {
      _weeklyBalance = orders.fold(0.0, (sum, order) => sum + order.total);
      notifyListeners();
    });

    _monthlyBalanceSub = _firestoreService
        .getDeliveredOrdersByStoreStream(storeId, startOfMonth, endOfMonth)
        .listen((orders) {
      _monthlyBalance = orders.fold(0.0, (sum, order) => sum + order.total);
      notifyListeners();
    });

    _totalBalanceSub = _firestoreService
        .getDeliveredOrdersByStoreStream(storeId, veryOldDate, now)
        .listen((orders) {
      _totalBalance = orders.fold(0.0, (sum, order) => sum + order.total);
      notifyListeners();
    });
  }

  void listenToAdminBalances() {
    _adminBalancesSub?.cancel();
    _adminBalancesSub =
        _firestoreService.getAllDeliveredOrdersStream().listen((orders) {
      // Calculate total platform balance
      _platformTotalBalance =
          orders.fold(0.0, (sum, order) => sum + order.total);

      // Calculate balance by seller
      final Map<String, StoreBalance> balances = {};
      for (var order in orders) {
        if (balances.containsKey(order.storeId)) {
          final existing = balances[order.storeId]!;
          balances[order.storeId] = StoreBalance(
            storeId: order.storeId,
            storeName: order.storeName,
            total: existing.total + order.total,
          );
        } else {
          balances[order.storeId] = StoreBalance(
            storeId: order.storeId,
            storeName: order.storeName,
            total: order.total,
          );
        }
      }
      _sellerBalances = balances.values.toList()
        ..sort((a, b) => b.total.compareTo(a.total));

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

  void _cancelBalanceSubscriptions() {
    _dailyBalanceSub?.cancel();
    _weeklyBalanceSub?.cancel();
    _monthlyBalanceSub?.cancel();
    _totalBalanceSub?.cancel();
    _adminBalancesSub?.cancel();
  }

  void clearListeners() {
    _ordersSubscription?.cancel();
    _cancelBalanceSubscriptions();
    _orders = [];
    _dailyBalance = 0.0;
    _weeklyBalance = 0.0;
    _monthlyBalance = 0.0;
    _totalBalance = 0.0;
    _platformTotalBalance = 0.0;
    _sellerBalances = [];
    // Comentado para evitar notificaciones innecesarias si no hay cambios reales.
    // notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _cancelBalanceSubscriptions();
    super.dispose();
  }
}
