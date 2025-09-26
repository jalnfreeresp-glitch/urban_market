// lib/services/firestore_service.dart (actualizado)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_market/models/order_model.dart' as custom_order;
import 'package:urban_market/models/product_model.dart' as custom_product;
import 'package:urban_market/models/store_model.dart' as custom_store;
import 'package:urban_market/models/user_model.dart' as custom_user;

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colecciones
  static const String _usersCollection = 'users';
  static const String _storesCollection = 'stores';
  static const String _productsCollection = 'products';
  static const String _ordersCollection = 'orders';

  // Usuarios
  static Future<void> createUser(custom_user.User user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .set(user.toJson());
  }

  static Future<custom_user.User?> getUser(String userId) async {
    final doc = await _firestore.collection(_usersCollection).doc(userId).get();
    if (doc.exists) {
      return custom_user.User.fromJson(doc.data()!);
    }
    return null;
  }

  static Stream<List<custom_user.User>> getUsersStream() {
    return _firestore.collection(_usersCollection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => custom_user.User.fromJson(doc.data()))
          .toList();
    });
  }

  static Future<List<custom_user.User>> getAllUsers() async {
    final snapshot = await _firestore.collection(_usersCollection).get();
    return snapshot.docs
        .map((doc) => custom_user.User.fromJson(doc.data()))
        .toList();
  }

  static Future<void> updateUser(custom_user.User user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .update(user.toJson());
  }

  // Tiendas
  static Future<void> createStore(custom_store.Store store) async {
    await _firestore
        .collection(_storesCollection)
        .doc(store.id)
        .set(store.toJson());
  }

  static Future<custom_store.Store?> getStore(String storeId) async {
    final doc =
        await _firestore.collection(_storesCollection).doc(storeId).get();
    if (doc.exists) {
      return custom_store.Store.fromJson(doc.data()!);
    }
    return null;
  }

  static Future<List<custom_store.Store>> getAllStores() async {
    final snapshot = await _firestore.collection(_storesCollection).get();
    return snapshot.docs
        .map((doc) => custom_store.Store.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_store.Store>> getActiveStores() async {
    final snapshot = await _firestore
        .collection(_storesCollection)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_store.Store.fromJson(doc.data()))
        .toList();
  }

  static Future<void> updateStore(custom_store.Store store) async {
    await _firestore
        .collection(_storesCollection)
        .doc(store.id)
        .update(store.toJson());
  }

  // Productos
  static Future<void> createProduct(custom_product.Product product) async {
    await _firestore
        .collection(_productsCollection)
        .doc(product.id)
        .set(product.toJson());
  }

  static Future<custom_product.Product?> getProduct(String productId) async {
    final doc =
        await _firestore.collection(_productsCollection).doc(productId).get();
    if (doc.exists) {
      return custom_product.Product.fromJson(doc.data()!);
    }
    return null;
  }

  static Future<List<custom_product.Product>> getProductsByStore(
      String storeId) async {
    final snapshot = await _firestore
        .collection(_productsCollection)
        .where('storeId', isEqualTo: storeId)
        .get();
    return snapshot.docs
        .map((doc) => custom_product.Product.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_product.Product>> getActiveProducts() async {
    final snapshot = await _firestore
        .collection(_productsCollection)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_product.Product.fromJson(doc.data()))
        .toList();
  }

  static Future<void> updateProduct(custom_product.Product product) async {
    await _firestore
        .collection(_productsCollection)
        .doc(product.id)
        .update(product.toJson());
  }

  static Future<void> deleteProduct(String productId) async {
    await _firestore.collection(_productsCollection).doc(productId).update({
      'isActive': false,
    });
  }

  // Pedidos
  static Future<void> createOrder(custom_order.Order order) async {
    await _firestore
        .collection(_ordersCollection)
        .doc(order.id)
        .set(order.toJson());
  }

  static Future<custom_order.Order?> getOrder(String orderId) async {
    final doc =
        await _firestore.collection(_ordersCollection).doc(orderId).get();
    if (doc.exists) {
      return custom_order.Order.fromJson(doc.data()!);
    }
    return null;
  }

  static Future<List<custom_order.Order>> getOrdersByUser(String userId) async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .where('customerId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_order.Order.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_order.Order>> getOrdersByStore(
      String storeId) async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .where('storeId', isEqualTo: storeId)
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_order.Order.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_order.Order>> getPendingOrders() async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .where('status', isEqualTo: custom_order.OrderStatus.pending.index)
        .get();
    return snapshot.docs
        .map((doc) => custom_order.Order.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_order.Order>> getOrdersByDeliveryPerson(
      String deliveryPersonId) async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .where('deliveryPersonId', isEqualTo: deliveryPersonId)
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_order.Order.fromJson(doc.data()))
        .toList();
  }

  // Método agregado para obtener todos los pedidos (para admin)
  static Future<List<custom_order.Order>> getAllOrders() async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_order.Order.fromJson(doc.data()))
        .toList();
  }

  static Future<void> updateOrderStatus(
      String orderId, custom_order.OrderStatus status) async {
    await _firestore.collection(_ordersCollection).doc(orderId).update({
      'status': status.index,
    });
  }

  static Future<void> assignDeliveryPerson(String orderId,
      String deliveryPersonId, String deliveryPersonName) async {
    await _firestore.collection(_ordersCollection).doc(orderId).update({
      'deliveryPersonId': deliveryPersonId,
      'deliveryPersonName': deliveryPersonName,
    });
  }
}