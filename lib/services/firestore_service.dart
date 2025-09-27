import 'package:flutter/foundation.dart';
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
  static Future<void> createUser(custom_user.UserModel user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .set(user.toJson());
  }

  static Future<custom_user.UserModel?> getUser(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        debugPrint('User data from Firestore: ${doc.data()}');
        // Aquí está el cambio clave:
        final data = doc.data();
        if (data is Map<String, dynamic>) {
          return custom_user.UserModel.fromJson(data);
        } else {
          debugPrint('Error: User data is not a Map<String, dynamic>. It is ${data.runtimeType}');
          // Considera devolver null o lanzar una excepción más específica.
          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  static Stream<List<custom_user.UserModel>> getUsersStream() {
    return _firestore.collection(_usersCollection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => custom_user.UserModel.fromJson(doc.data()))
          .toList();
    });
  }

  static Future<List<custom_user.UserModel>> getAllUsers() async {
    final snapshot = await _firestore.collection(_usersCollection).get();
    return snapshot.docs
        .map((doc) => custom_user.UserModel.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_user.UserModel>> getSellers() async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('role', isEqualTo: 'Vendedor')
        .get();
    return snapshot.docs
        .map((doc) => custom_user.UserModel.fromJson(doc.data()))
        .toList();
  }

  static Future<void> updateUser(custom_user.UserModel user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .update(user.toJson());
  }

  // Tiendas
  static Future<custom_store.StoreModel> createStore(
      custom_store.StoreModel store) async {
    final doc = _firestore.collection(_storesCollection).doc();
    final newStore = store.copyWith(id: doc.id);
    await doc.set(newStore.toJson());
    return newStore;
  }

  static Future<custom_store.StoreModel?> getStore(String storeId) async {
    final doc =
        await _firestore.collection(_storesCollection).doc(storeId).get();
    if (doc.exists) {
      return custom_store.StoreModel.fromJson(doc.data()!);
    }
    return null;
  }

  static Future<List<custom_store.StoreModel>> getAllStores() async {
    final snapshot = await _firestore.collection(_storesCollection).get();
    return snapshot.docs
        .map((doc) => custom_store.StoreModel.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_store.StoreModel>> getActiveStores() async {
    final snapshot = await _firestore
        .collection(_storesCollection)
        .where('isActive', isEqualTo: true)
        .where('isOpen', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_store.StoreModel.fromJson(doc.data()))
        .toList();
  }

  static Future<custom_store.StoreModel?> getStoreByOwner(
      String ownerId) async {
    final snapshot = await _firestore
        .collection(_storesCollection)
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return custom_store.StoreModel.fromJson(snapshot.docs.first.data());
    }
    return null;
  }

  static Future<void> updateStore(custom_store.StoreModel store) async {
    await _firestore
        .collection(_storesCollection)
        .doc(store.id)
        .update(store.toJson());
  }

  // Productos
  static Future<void> createProduct(custom_product.ProductModel product) async {
    await _firestore
        .collection(_productsCollection)
        .doc(product.id)
        .set(product.toJson());
  }

  static Future<custom_product.ProductModel?> getProduct(
      String productId) async {
    final doc =
        await _firestore.collection(_productsCollection).doc(productId).get();
    if (doc.exists) {
      return custom_product.ProductModel.fromJson(doc.data()!);
    }
    return null;
  }

  static Future<List<custom_product.ProductModel>> getProductsByStore(
      String storeId) async {
    final snapshot = await _firestore
        .collection(_productsCollection)
        .where('storeId', isEqualTo: storeId)
        .get();
    return snapshot.docs
        .map((doc) => custom_product.ProductModel.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_product.ProductModel>> getActiveProducts() async {
    final snapshot = await _firestore
        .collection(_productsCollection)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_product.ProductModel.fromJson(doc.data()))
        .toList();
  }

  static Future<void> updateProduct(custom_product.ProductModel product) async {
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
  static Future<void> createOrder(custom_order.OrderModel order) async {
    await _firestore
        .collection(_ordersCollection)
        .doc(order.id)
        .set(order.toJson());
  }

  static Future<custom_order.OrderModel?> getOrder(String orderId) async {
    final doc =
        await _firestore.collection(_ordersCollection).doc(orderId).get();
    if (doc.exists) {
      return custom_order.OrderModel.fromJson(doc.data()!);
    }
    return null;
  }

  static Future<List<custom_order.OrderModel>> getOrdersByUser(
      String userId) async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .where('customerId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_order.OrderModel.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_order.OrderModel>> getOrdersByStore(
      String storeId) async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .where('storeId', isEqualTo: storeId)
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_order.OrderModel.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_order.OrderModel>> getPendingOrders() async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .where('status',
            isEqualTo: custom_order.OrderStatus.pendientePago.index)
        .get();
    return snapshot.docs
        .map((doc) => custom_order.OrderModel.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_order.OrderModel>> getInProcessOrders() async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .where('status', isEqualTo: custom_order.OrderStatus.enProceso.index)
        .get();
    return snapshot.docs
        .map((doc) => custom_order.OrderModel.fromJson(doc.data()))
        .toList();
  }

  static Future<List<custom_order.OrderModel>> getOrdersByDeliveryPerson(
      String deliveryPersonId) async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .where('deliveryPersonId', isEqualTo: deliveryPersonId)
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_order.OrderModel.fromJson(doc.data()))
        .toList();
  }

  // Método agregado para obtener todos los pedidos (para admin)
  static Future<List<custom_order.OrderModel>> getAllOrders() async {
    final snapshot = await _firestore
        .collection(_ordersCollection)
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => custom_order.OrderModel.fromJson(doc.data()))
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
