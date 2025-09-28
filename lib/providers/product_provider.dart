import 'dart:async';
import 'package:flutter/foundation.dart';
// Se añaden alias para consistencia
import 'package:urban_market/models/product_model.dart' as pm;
import 'package:urban_market/models/store_model.dart' as sm;
import 'package:urban_market/providers/auth_provider.dart';
import 'package:urban_market/services/firestore_service.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthProvider? _authProvider;

  List<pm.ProductModel> _products = [];
  List<sm.StoreModel> _stores = [];
  List<pm.ProductModel> _sellerProducts = [];
  List<pm.ProductModel> _filteredProducts = [];

  StreamSubscription? _productsSubscription;
  StreamSubscription? _storesSubscription;
  StreamSubscription? _sellerProductsSubscription;

  bool _isLoading = false;

  // --- Getters ---
  List<pm.ProductModel> get products => _products;
  List<sm.StoreModel> get stores => _stores;
  List<pm.ProductModel> get sellerProducts => _sellerProducts;
  List<pm.ProductModel> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading;

  ProductProvider(this._authProvider) {
    _listenToActiveProducts();
    _listenToActiveStores();
    // Inicia la escucha de productos del vendedor si el rol es correcto.
    if (_authProvider?.user?.role == 'Vendedor') {
      listenToSellerProducts();
    }
  }

  void _listenToActiveProducts() {
    _isLoading = true;
    notifyListeners();
    _productsSubscription =
        _firestoreService.getActiveProductsStore().listen((productsData) {
      _products = productsData;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error listening to products: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  void _listenToActiveStores() {
    _storesSubscription =
        _firestoreService.getActiveStoresStream().listen((storesData) {
      _stores = storesData;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error listening to stores: $error');
    });
  }

  void listenToSellerProducts() {
    final storeId = _authProvider?.user?.storeId;
    if (storeId == null) return;

    // Escucha los productos específicos de la tienda del vendedor.
    _sellerProductsSubscription =
        _firestoreService.getProductsByStoreStream(storeId).listen((products) {
      _sellerProducts = products;
      notifyListeners();
    });
  }

  void filterProductsByStore(String storeId) {
    _filteredProducts =
        _products.where((product) => product.storeId == storeId).toList();
    notifyListeners();
  }

  List<pm.ProductModel> getProductsByStore(String storeId) {
    return _products.where((product) => product.storeId == storeId).toList();
  }

  Future<void> addProduct(pm.ProductModel product) async {
    try {
      await _firestoreService.createProduct(product);
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(pm.ProductModel product) async {
    try {
      await _firestoreService.updateProduct(product);
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _storesSubscription?.cancel();
    _sellerProductsSubscription?.cancel();
    super.dispose();
  }
}
