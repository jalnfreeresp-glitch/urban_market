// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urban_market/models/order_model.dart' as om;
import 'package:urban_market/models/product_model.dart' as pm;
import 'package:urban_market/models/store_model.dart' as sm;
import 'package:urban_market/models/user_model.dart' as um;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<um.UserModel> get _users =>
      _db.collection('users').withConverter<um.UserModel>(
            fromFirestore: (snap, _) =>
                um.UserModel.fromMap(snap.id, snap.data()!),
            toFirestore: (user, _) => user.toMap(),
          );

  CollectionReference<sm.StoreModel> get _stores =>
      _db.collection('stores').withConverter<sm.StoreModel>(
            fromFirestore: (snap, _) =>
                sm.StoreModel.fromMap(snap.id, snap.data()!),
            toFirestore: (store, _) => store.toMap(),
          );

  CollectionReference<pm.ProductModel> get _products =>
      _db.collection('products').withConverter<pm.ProductModel>(
            fromFirestore: (snap, _) =>
                pm.ProductModel.fromMap(snap.id, snap.data()!),
            toFirestore: (product, _) => product.toMap(),
          );

  CollectionReference<om.OrderModel> get _orders =>
      _db.collection('orders').withConverter<om.OrderModel>(
            fromFirestore: (snap, _) =>
                om.OrderModel.fromMap(snap.id, snap.data()!),
            toFirestore: (order, _) => order.toMap(),
          );

  // --- MÉTODOS DE USUARIO ---
  Future<void> createUser(um.UserModel user) => _users.doc(user.id).set(user);
  Future<um.UserModel?> getUser(String userId) async =>
      (await _users.doc(userId).get()).data();
  Stream<List<um.UserModel>> getUsersStream() => _users
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  Future<void> updateUser(um.UserModel user) =>
      _users.doc(user.id).update(user.toMap());

  Stream<List<um.UserModel>> getSellersStream() => _users
      .where('role', isEqualTo: 'Vendedor')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  // --- MÉTODOS DE TIENDA ---
  Future<void> createStore(sm.StoreModel store) =>
      _stores.doc(store.id).set(store);

  Stream<List<sm.StoreModel>> getStoresStream() => _stores
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Stream<List<sm.StoreModel>> getActiveStoresStream() => _stores
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Stream<List<sm.StoreModel>> getActiveStoresStreamByCategory(String category) => _stores
      .where('isActive', isEqualTo: true)
      .where('category', isEqualTo: category)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Future<sm.StoreModel?> getStoreByOwner(String ownerId) async {
    final snap =
        await _stores.where('ownerId', isEqualTo: ownerId).limit(1).get();
    return snap.docs.isNotEmpty ? snap.docs.first.data() : null;
  }

  Future<void> updateStore(sm.StoreModel store) =>
      _stores.doc(store.id).update(store.toMap());
  Future<sm.StoreModel?> getStore(String storeId) async =>
      (await _stores.doc(storeId).get()).data();

  // Nuevo método: crear tienda y asignarla a un vendedor
  Future<void> createStoreForSeller(
      sm.StoreModel store, String sellerId) async {
    final storeRef = _stores.doc(store.id);
    final userRef = _users.doc(sellerId);
    await _db.runTransaction((transaction) async {
      transaction.set(storeRef, store);
      transaction.update(userRef, {'storeId': store.id});
    });
  }

  // --- MÉTODOS DE PRODUCTO ---
  Future<void> createProduct(pm.ProductModel product) =>
      _products.doc(product.id).set(product);
  Stream<List<pm.ProductModel>> getActiveProductsStore() => _products
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  Stream<List<pm.ProductModel>> getProductsByStoreStream(String storeId) =>
      _products
          .where('storeId', isEqualTo: storeId)
          .snapshots()
          .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  Future<void> updateProduct(pm.ProductModel product) =>
      _products.doc(product.id).update(product.toMap());

  Future<void> deleteProduct(String productId) => _products.doc(productId).delete();

  // --- MÉTODOS DE ÓRDENES ---
  Future<void> createOrder(om.OrderModel order) =>
      _orders.doc(order.id).set(order);

  Stream<List<om.OrderModel>> getOrdersByUserStream(String userId) => _orders
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Stream<List<om.OrderModel>> getOrdersByStoreStream(String storeId) => _orders
      .where('storeId', isEqualTo: storeId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Stream<List<om.OrderModel>> getDeliveredOrdersByStoreStream(
          String storeId, DateTime start, DateTime end) =>
      _orders
          .where('storeId', isEqualTo: storeId)
          .where('status', isEqualTo: om.OrderStatus.delivered.name)
          .where('createdAt', isGreaterThanOrEqualTo: start)
          .where('createdAt', isLessThanOrEqualTo: end)
          .snapshots()
          .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Stream<List<om.OrderModel>> getOrdersByDeliveryPersonStream(
          String deliveryPersonId) =>
      _orders
          .where('deliveryPersonId', isEqualTo: deliveryPersonId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Stream<List<om.OrderModel>> getAllOrdersStream() => _orders
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Stream<List<om.OrderModel>> getAllDeliveredOrdersStream() => _orders
      .where('status', isEqualTo: om.OrderStatus.delivered.name)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Stream<List<om.OrderModel>> getOrdersByStatusStream(om.OrderStatus status) =>
      _orders
          .where('status', isEqualTo: status.name)
          .snapshots()
          .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Future<void> updateOrderStatus(String orderId, om.OrderStatus newStatus) =>
      _orders.doc(orderId).update({'status': newStatus.name});
}